#!/usr/bin/env python3
"""Check that source files stay under a configurable line limit.

Large files indicate mixed responsibilities. They are harder for agents
to reason about and more likely to cause merge conflicts.

Usage:
    python lints/python/check_file_sizes.py [--max-lines N] [--path DIR]

Exit codes:
    0 — No violations
    1 — One or more files exceed the limit
"""

import argparse
import sys
from pathlib import Path

DEFAULT_MAX_LINES = 300
DEFAULT_PATH = "."
EXTENSIONS = {".py"}
SKIP_DIRS = {"__pycache__", ".git", "node_modules", "venv", ".venv", ".tox", "dist", "build"}


def find_source_files(root: Path) -> list[Path]:
    """Recursively find source files, skipping excluded directories."""
    files = []
    for item in root.rglob("*"):
        if any(part in SKIP_DIRS for part in item.parts):
            continue
        if item.is_file() and item.suffix in EXTENSIONS:
            files.append(item)
    return sorted(files)


def check_file_size(filepath: Path, max_lines: int) -> str | None:
    """Return a violation string if the file exceeds max_lines, else None."""
    try:
        lines = filepath.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return None

    count = len(lines)
    if count <= max_lines:
        return None

    return (
        f"VIOLATION: File Size Limit\n"
        f"FILE: {filepath}:{count}\n"
        f"RULE: Source files must be under {max_lines} lines\n"
        f"WHY: Large files indicate mixed responsibilities. They are harder for "
        f"agents to reason about and more likely to cause merge conflicts.\n"
        f"FIX: Extract related functions into a new module. Split by responsibility "
        f"(e.g., {filepath.stem}_core.py, {filepath.stem}_helpers.py).\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Check source file sizes")
    parser.add_argument("--max-lines", type=int, default=DEFAULT_MAX_LINES,
                        help=f"Maximum lines per file (default: {DEFAULT_MAX_LINES})")
    parser.add_argument("--path", type=str, default=DEFAULT_PATH,
                        help=f"Root directory to scan (default: {DEFAULT_PATH})")
    args = parser.parse_args()

    root = Path(args.path)
    if not root.is_dir():
        print(f"Error: {root} is not a directory", file=sys.stderr)
        return 1

    files = find_source_files(root)
    violations = []

    for f in files:
        violation = check_file_size(f, args.max_lines)
        if violation:
            violations.append(violation)

    if not violations:
        print(f"OK: All {len(files)} files are under {args.max_lines} lines")
        return 0

    for v in violations:
        print(v)

    print(f"FAILED: {len(violations)} file(s) exceed {args.max_lines} lines")
    return 1


if __name__ == "__main__":
    sys.exit(main())
