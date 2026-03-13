#!/usr/bin/env python3
"""Check that imports respect architectural layer boundaries.

Layers are defined top-down: higher layers may import lower layers,
but lower layers must never import higher layers. This prevents
circular dependencies and keeps the dependency graph clean.

Usage:
    python lints/python/check_imports.py [--path DIR] [--layers LAYERS]

    --layers: Comma-separated list from highest to lowest layer.
              Example: "routers,services,models,utils"
              This means routers can import services, models, utils;
              services can import models, utils; etc.
              models and utils cannot import routers or services.

Exit codes:
    0 — No violations
    1 — One or more import direction violations found
"""

import argparse
import ast
import sys
from pathlib import Path

DEFAULT_PATH = "."
# Default layers from highest (can import everything below) to lowest
# Customize for your project's architecture
DEFAULT_LAYERS = "routers,services,models,utils"
SKIP_DIRS = {"__pycache__", ".git", "node_modules", "venv", ".venv", ".tox", "dist", "build", "tests"}


def parse_layers(layers_str: str) -> list[str]:
    """Parse comma-separated layer names into ordered list (high to low)."""
    return [layer.strip() for layer in layers_str.split(",") if layer.strip()]


def get_layer(filepath: Path, layers: list[str]) -> str | None:
    """Determine which layer a file belongs to based on its path."""
    parts = filepath.parts
    for layer in layers:
        if layer in parts:
            return layer
    return None


def get_imported_layers(filepath: Path, layers: list[str]) -> list[tuple[str, int]]:
    """Parse a Python file and return imported layer names with line numbers."""
    try:
        source = filepath.read_text(encoding="utf-8", errors="replace")
        tree = ast.parse(source, filename=str(filepath))
    except (OSError, SyntaxError):
        return []

    imported = []
    for node in ast.walk(tree):
        module_name = None
        lineno = 0

        if isinstance(node, ast.Import):
            for alias in node.names:
                module_name = alias.name
                lineno = node.lineno
        elif isinstance(node, ast.ImportFrom) and node.module:
            module_name = node.module
            lineno = node.lineno

        if module_name:
            parts = module_name.split(".")
            for part in parts:
                if part in layers:
                    imported.append((part, lineno))
                    break

    return imported


def check_import_direction(filepath: Path, layers: list[str]) -> list[str]:
    """Check that imports only go downward in the layer hierarchy."""
    file_layer = get_layer(filepath, layers)
    if file_layer is None:
        return []

    file_layer_index = layers.index(file_layer)
    imported = get_imported_layers(filepath, layers)
    violations = []

    for imported_layer, lineno in imported:
        imported_index = layers.index(imported_layer)
        # Lower index = higher layer. A file should only import from
        # layers with higher index (lower in the stack).
        if imported_index < file_layer_index:
            violations.append(
                f"VIOLATION: Import Direction\n"
                f"FILE: {filepath}:{lineno}\n"
                f"RULE: Layer '{file_layer}' must not import from higher layer '{imported_layer}'\n"
                f"WHY: Lower layers importing higher layers creates circular dependencies "
                f"and couples implementation details to interfaces. The dependency arrow "
                f"must always point downward.\n"
                f"FIX: Move the shared logic into a lower layer that both can import, "
                f"or pass the dependency as a parameter (dependency injection).\n"
            )

    return violations


def find_python_files(root: Path) -> list[Path]:
    """Recursively find Python files, skipping excluded directories."""
    files = []
    for item in root.rglob("*.py"):
        if any(part in SKIP_DIRS for part in item.parts):
            continue
        if item.is_file():
            files.append(item)
    return sorted(files)


def main() -> int:
    parser = argparse.ArgumentParser(description="Check import layer direction")
    parser.add_argument("--path", type=str, default=DEFAULT_PATH,
                        help=f"Root directory to scan (default: {DEFAULT_PATH})")
    parser.add_argument("--layers", type=str, default=DEFAULT_LAYERS,
                        help=f"Comma-separated layers, highest to lowest (default: {DEFAULT_LAYERS})")
    args = parser.parse_args()

    root = Path(args.path)
    if not root.is_dir():
        print(f"Error: {root} is not a directory", file=sys.stderr)
        return 1

    layers = parse_layers(args.layers)
    if len(layers) < 2:
        print("Error: need at least 2 layers to check direction", file=sys.stderr)
        return 1

    files = find_python_files(root)
    all_violations = []

    for f in files:
        violations = check_import_direction(f, layers)
        all_violations.extend(violations)

    if not all_violations:
        print(f"OK: All imports in {len(files)} files respect layer boundaries ({' → '.join(layers)})")
        return 0

    for v in all_violations:
        print(v)

    print(f"FAILED: {len(all_violations)} import direction violation(s) found")
    return 1


if __name__ == "__main__":
    sys.exit(main())
