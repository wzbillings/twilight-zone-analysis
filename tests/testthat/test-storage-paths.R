source(file.path("..", "..", "R", "00_paths.R"), local = TRUE)

local_storage <- function(env = parent.frame()) {
  variables <- c("TZ_OBSERVATIONS_ROOT", "TZ_CORPUS_ROOT", "TZ_DERIVED_ROOT",
                 "TZ_LOGS_ROOT", "TZ_TARGETS_STORE")
  withr::local_envvar(setNames(rep(NA_character_, length(variables)), variables),
                    .local_envir = env)
  parent <- withr::local_tempdir(pattern = "storage fixtures ", .local_envir = env)
  roots <- file.path(parent, c("observations", "corpus", "derived", "logs"))
  for (root in roots) dir.create(root)
  do.call(Sys.setenv, as.list(setNames(roots, variables[1:4])))
  roots
}

testthat::test_that("siblings and future descendants resolve without writes", {
  roots <- local_storage()
  helpers <- list(observations_path, corpus_path, derived_path, logs_path)
  config <- validate_storage_config()
  for (i in seq_along(roots)) {
    expected <- as.character(fs::path_real(roots[i]))
    testthat::expect_identical(helpers[[i]](), expected)
    testthat::expect_identical(config[[i]], expected)
    child <- helpers[[i]]("future folder/nested", "file.csv")
    testthat::expect_identical(child, paste0(expected, "/future folder/nested/file.csv"))
    testthat::expect_false(file.exists(dirname(child)))
  }
  testthat::expect_null(config$targets)
})

testthat::test_that("required variables fail with configuration guidance", {
  roots <- local_storage()
  for (value in c(NA_character_, "", "   ", "relative/path", paste0(roots[1], "/missing"))) {
    withr::with_envvar(c(TZ_OBSERVATIONS_ROOT = value), {
      testthat::expect_error(observations_path(), "TZ_OBSERVATIONS_ROOT.*[.]Renviron")
    })
  }
  file <- file.path(roots[1], "file")
  file.create(file)
  withr::with_envvar(c(TZ_OBSERVATIONS_ROOT = file), {
    testthat::expect_error(observations_path(), "TZ_OBSERVATIONS_ROOT.*directory")
  })
})

testthat::test_that("public repository and overlapping domains are rejected", {
  roots <- local_storage()
  for (path in c(project_path(), project_path("R"), dirname(project_path()))) {
    withr::with_envvar(c(TZ_CORPUS_ROOT = path), {
      testthat::expect_error(corpus_path(), "TZ_CORPUS_ROOT.*public")
    })
  }
  nested <- file.path(roots[1], "nested")
  dir.create(nested)
  for (path in c(roots[1], nested)) {
    withr::with_envvar(c(TZ_CORPUS_ROOT = path), {
      testthat::expect_error(validate_storage_config(), "TZ_OBSERVATIONS_ROOT.*TZ_CORPUS_ROOT")
    })
  }
})

testthat::test_that("targets store is optional and has no placement policy", {
  local_storage()
  testthat::expect_null(targets_store_path())
  testthat::expect_null(targets_store_path("future"))
  withr::with_envvar(c(TZ_TARGETS_STORE = "  "), testthat::expect_null(targets_store_path()))
  withr::with_envvar(c(TZ_TARGETS_STORE = project_path()), {
    testthat::expect_identical(targets_store_path(), project_path())
    testthat::expect_identical(validate_storage_config()$targets, project_path())
  })
  withr::with_envvar(c(TZ_TARGETS_STORE = "relative"), {
    testthat::expect_error(targets_store_path(), "TZ_TARGETS_STORE.*absolute")
  })
})

testthat::test_that("children cannot escape a root or use malformed components", {
  local_storage()
  for (child in list("../escape", "nested/../../escape", "/absolute", "C:/absolute",
                     "C:relative", "\\\\server\\share", "bad\nname", NA_character_,
                     c("a", "b"), "", "bad:name")) {
    testthat::expect_error(corpus_path(child), "component")
  }
  testthat::expect_identical(corpus_path("a\\b"), corpus_path("a", "b"))
})

testthat::test_that("project discovery and removed legacy helpers are unambiguous", {
  root <- project_path()
  testthat::expect_true(file.exists(file.path(root, "_targets.R")))
  testthat::expect_identical(output_path("table.csv"), paste0(root, "/output/table.csv"))
  isolated <- new.env(parent = baseenv())
  sys.source(file.path(root, "R", "00_paths.R"), isolated)
  for (name in c("data_raw_path", "data_interim_path", "data_features_path", "data_analytic_path")) {
    testthat::expect_false(exists(name, isolated, inherits = FALSE))
  }
})

testthat::test_that("sourcing all modules needs no storage variables", {
  local_storage()
  Sys.unsetenv(c("TZ_OBSERVATIONS_ROOT", "TZ_CORPUS_ROOT", "TZ_DERIVED_ROOT",
                "TZ_LOGS_ROOT", "TZ_TARGETS_STORE"))
  isolated <- new.env(parent = baseenv())
  for (file in list.files(project_path("R"), full.names = TRUE, pattern = "[.]R$")) {
    testthat::expect_silent(sys.source(file, isolated))
  }
})

testthat::test_that("configuration changes relocate paths without code changes", {
  roots <- local_storage()
  before <- observations_path("modern", "imdb")
  replacement <- file.path(dirname(roots[1]), "relocated observations")
  dir.create(replacement)
  Sys.setenv(TZ_OBSERVATIONS_ROOT = replacement)
  testthat::expect_identical(observations_path("modern", "imdb"),
                            paste0(as.character(fs::path_real(replacement)), "/modern/imdb"))
  testthat::expect_false(identical(before, observations_path("modern", "imdb")))
  testthat::expect_length(list.files(replacement, all.files = TRUE, no.. = TRUE), 0L)
  Sys.unsetenv("TZ_CORPUS_ROOT")
  testthat::expect_silent(observations_path())
  testthat::expect_error(validate_storage_config(), "TZ_CORPUS_ROOT")
})

testthat::test_that("malformed roots and missing optional directories fail clearly", {
  roots <- local_storage()
  for (value in c("bad\npath", '"quoted/path"', paste0(roots[1], "/*"))) {
    withr::with_envvar(c(TZ_DERIVED_ROOT = value), {
      testthat::expect_error(derived_path(), "TZ_DERIVED_ROOT.*malformed.*[.]Renviron")
    })
  }
  withr::with_envvar(c(TZ_TARGETS_STORE = paste0(roots[1], "/absent")), {
    testthat::expect_error(targets_store_path(), "TZ_TARGETS_STORE.*existing directory")
    testthat::expect_false(dir.exists(Sys.getenv("TZ_TARGETS_STORE")))
  })
  testthat::expect_error(storage_root("unknown"), "Unknown storage domain")
})

testthat::test_that("Windows separators, case and drive-relative paths are handled", {
  testthat::skip_if(.Platform$OS.type != "windows", "Windows semantics")
  roots <- local_storage()
  withr::with_envvar(c(TZ_CORPUS_ROOT = chartr("/", "\\", paste0(roots[2], "/."))), {
    testthat::expect_identical(corpus_path(), as.character(fs::path_real(roots[2])))
  })
  for (value in c("C:relative", "/current-drive", "\\current-drive", "//server")) {
    withr::with_envvar(c(TZ_CORPUS_ROOT = value), {
      testthat::expect_error(corpus_path(), "TZ_CORPUS_ROOT.*absolute")
    })
  }
  withr::with_envvar(c(TZ_CORPUS_ROOT = toupper(project_path())), {
    testthat::expect_error(corpus_path(), "TZ_CORPUS_ROOT.*public")
  })
  withr::with_envvar(c(TZ_CORPUS_ROOT = toupper(roots[1])), {
    testthat::expect_error(validate_storage_config(), "TZ_OBSERVATIONS_ROOT.*TZ_CORPUS_ROOT")
  })
  for (child in c("name.", "name ", "NUL", "con.txt", "folder/LPT1")) {
    testthat::expect_error(corpus_path(child), "component")
  }
})

testthat::test_that("physical links cannot bypass root or descendant separation", {
  roots <- local_storage()
  make_link <- function(target, link) {
    if (.Platform$OS.type == "windows") Sys.junction(target, link) else file.symlink(target, link)
  }
  public_link <- file.path(dirname(roots[1]), "public link")
  testthat::expect_true(make_link(project_path(), public_link))
  withr::with_envvar(c(TZ_CORPUS_ROOT = public_link), {
    testthat::expect_error(corpus_path(), "TZ_CORPUS_ROOT.*public")
  })
  escape <- file.path(roots[2], "escape")
  testthat::expect_true(make_link(roots[1], escape))
  testthat::expect_error(corpus_path("escape", "future", "file.csv"), "outside its root")
  nested <- file.path(roots[1], "nested")
  dir.create(nested)
  alias <- file.path(dirname(roots[1]), "alias")
  testthat::expect_true(make_link(nested, alias))
  withr::with_envvar(c(TZ_CORPUS_ROOT = alias), {
    testthat::expect_error(validate_storage_config(), "TZ_OBSERVATIONS_ROOT.*TZ_CORPUS_ROOT")
  })
})

testthat::test_that("the committed environment template is safe and readable", {
  local_storage()
  testthat::expect_true(readRenviron(project_path(".Renviron.example")))
  variables <- c("TZ_OBSERVATIONS_ROOT", "TZ_CORPUS_ROOT", "TZ_DERIVED_ROOT",
                 "TZ_LOGS_ROOT", "TZ_TARGETS_STORE")
  testthat::expect_true(all(Sys.getenv(variables) == ""))
})
