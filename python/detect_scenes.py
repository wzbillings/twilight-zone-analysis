"""Eventually use PySceneDetect to emit one row per detected shot/scene.

Expected eventual CSV columns:
episode_id, video_path, scene_number, start_time_seconds, end_time_seconds, duration_seconds

Scaffold only. No media is read and no extraction packages are imported.
"""

import argparse
from pathlib import Path


OUTPUT_COLUMNS = ('episode_id', 'video_path', 'scene_number', 'start_time_seconds', 'end_time_seconds', 'duration_seconds')


def build_parser():
    """Describe the future single-episode extraction interface."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--episode-id", required=True, help="Canonical episode identifier")
    parser.add_argument("--input", required=True, type=Path, help="Local input media path")
    parser.add_argument("--output", required=True, type=Path, help="Future output CSV path")
    return parser


def main():
    """Parse arguments and fail clearly until extraction is implemented."""
    parser = build_parser()
    args = parser.parse_args()
    # TODO: Validate local media and implement extraction using args.
    # TODO: Write OUTPUT_COLUMNS only after successful extraction.
    parser.exit(1, "Not implemented yet. No input was read or output created.\n")


if __name__ == "__main__":
    main()
