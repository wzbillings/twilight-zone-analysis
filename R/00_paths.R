# Paths are resolved at call time; sourcing never reads configuration or writes files.

storage_error <- function(variable, problem) {
  stop(variable, ": ", problem,
       ". Configure it in machine-local .Renviron or the process environment.",
       call. = FALSE)
}

path_is_within <- function(path, root) {
  if (.Platform$OS.type == "windows") {
    path <- tolower(path)
    root <- tolower(root)
  }
  identical(path, root) || startsWith(path, paste0(sub("/+$", "", root), "/"))
}

# Resolve existing ancestors too, so links cannot hide an escaping future child.
physical_path <- function(path) {
  if (fs::file_exists(path) || fs::dir_exists(path)) {
    return(as.character(fs::path_real(path)))
  }
  if (fs::link_exists(path)) stop("Dangling link in path", call. = FALSE)
  parent <- dirname(path)
  if (identical(parent, path)) stop("Cannot resolve path ancestor", call. = FALSE)
  file.path(physical_path(parent), basename(path))
}

valid_path_text <- function(path) {
  is.character(path) && length(path) == 1L && !is.na(path) &&
    nzchar(trimws(path)) && !grepl('[[:cntrl:]<>"|?*]', path)
}

# Fully qualified native paths only: drive-relative and current-drive paths on
# Windows are not absolute. UNC paths must name both server and share.
absolute_storage_path <- function(path) {
  if (.Platform$OS.type == "windows") {
    grepl("^[A-Za-z]:/", path) || grepl("^//[^/]+/[^/]+(/|$)", path)
  } else {
    startsWith(path, "/")
  }
}

#' Construct a public project path from the project or any subdirectory.
#' @param ... Scalar relative character path components.
#' @return A normalized character path. No directories are created.
project_path <- function(...) {
  root <- as.character(fs::path_real(getwd()))
  repeat {
    if (file.exists(file.path(root, "_targets.R")) &&
        file.exists(file.path(root, "R", "00_paths.R"))) break
    parent <- dirname(root)
    if (identical(parent, root)) {
      stop("Cannot find public project; run from the project or a subdirectory.",
           call. = FALSE)
    }
    root <- parent
  }
  descendant_path(root, ...)
}

#' Resolve one configured storage root without creating it.
#' @param domain One of observations, corpus, derived, logs, targets.
#' @return An existing absolute directory, or NULL for an unset targets store.
#' @details External roots cannot overlap the public repository. Use
#' validate_storage_config() to check separation between external domains.
storage_root <- function(domain) {
  variables <- c(observations = "TZ_OBSERVATIONS_ROOT", corpus = "TZ_CORPUS_ROOT",
                 derived = "TZ_DERIVED_ROOT", logs = "TZ_LOGS_ROOT",
                 targets = "TZ_TARGETS_STORE")
  if (length(domain) != 1L || is.na(domain) || !domain %in% names(variables)) {
    stop("Unknown storage domain; use observations, corpus, derived, logs, or targets.",
         call. = FALSE)
  }
  variable <- unname(variables[[domain]])
  value <- Sys.getenv(variable, unset = "")
  if (!nzchar(trimws(value))) {
    if (domain == "targets") return(NULL)
    storage_error(variable, "required root is unset or blank")
  }
  if (!valid_path_text(value)) storage_error(variable, "malformed directory path")
  value <- gsub("\\", "/", value, fixed = TRUE)
  if (!absolute_storage_path(value)) storage_error(variable, "root must be absolute")
  # Reject alternate data streams and extra drive delimiters on Windows.
  if (.Platform$OS.type == "windows" && grepl(":", sub("^[A-Za-z]:", "", value))) {
    storage_error(variable, "malformed directory path")
  }
  if (!dir.exists(value)) storage_error(variable, "root must be an existing directory")
  root <- tryCatch(as.character(fs::path_real(value)), error = function(e) {
    storage_error(variable, "directory could not be resolved")
  })
  if (domain != "targets") {
    public <- project_path()
    if (path_is_within(root, public) || path_is_within(public, root)) {
      storage_error(variable, "root must not overlap the public repository")
    }
  }
  root
}

#' Validate all four required roots and the optional targets store.
#' @return Named list of normalized roots (targets may be NULL).
validate_storage_config <- function() {
  domains <- c("observations", "corpus", "derived", "logs", "targets")
  roots <- setNames(lapply(domains, storage_root), domains)
  for (i in 1:3) {
    for (j in (i + 1):4) {
      if (path_is_within(roots[[i]], roots[[j]]) ||
          path_is_within(roots[[j]], roots[[i]])) {
        storage_error(paste0("TZ_", toupper(domains[i]), "_ROOT"),
                      paste0("must be distinct from and not nested with TZ_",
                             toupper(domains[j]), "_ROOT"))
      }
    }
  }
  roots
}

# Internal shared child validation, including physical containment of links.
descendant_path <- function(root, ...) {
  components <- list(...)
  path <- root
  for (component in components) {
    if (!valid_path_text(component)) stop("Invalid path component", call. = FALSE)
    component <- gsub("\\", "/", component, fixed = TRUE)
    pieces <- strsplit(component, "/", fixed = TRUE)[[1]]
    if (startsWith(component, "/") || grepl(":", component, fixed = TRUE) ||
        any(pieces == "..")) {
      stop("Path component must be relative and must not contain parent traversal",
           call. = FALSE)
    }
    if (.Platform$OS.type == "windows" &&
        any(grepl("[. ]$", pieces[pieces != "."]) |
            grepl("^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])([.]|$)", pieces[pieces != "."],
                  ignore.case = TRUE))) {
      stop("Invalid Windows path component", call. = FALSE)
    }
    path <- as.character(fs::path_norm(file.path(path, component)))
    resolved <- tryCatch(physical_path(path), error = function(e) {
      stop("Path component could not be resolved", call. = FALSE)
    })
    if (!path_is_within(resolved, root)) {
      stop("Path component resolves outside its root", call. = FALSE)
    }
    path <- resolved
  }
  path
}

#' Construct a path in the local observations repository; never creates it.
observations_path <- function(...) descendant_path(storage_root("observations"), ...)

#' Construct a path in the non-Git corpus; never creates it.
corpus_path <- function(...) descendant_path(storage_root("corpus"), ...)

#' Construct a path in non-Git derived storage; never creates it.
derived_path <- function(...) descendant_path(storage_root("derived"), ...)

#' Construct a path in non-Git runtime logs; never creates it.
logs_path <- function(...) descendant_path(storage_root("logs"), ...)

#' Construct an optional store path, or return NULL if unset; does not wire targets.
targets_store_path <- function(...) {
  root <- storage_root("targets")
  if (is.null(root)) return(NULL)
  descendant_path(root, ...)
}

#' Construct a public output path; never creates it.
output_path <- function(...) project_path("output", ...)
