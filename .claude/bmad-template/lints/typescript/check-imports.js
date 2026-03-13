#!/usr/bin/env node
/**
 * Check that imports respect architectural layer boundaries.
 *
 * Layers are defined top-down: higher layers may import lower layers,
 * but lower layers must never import higher layers. This prevents
 * circular dependencies and keeps the dependency graph clean.
 *
 * Usage:
 *   node lints/typescript/check-imports.js [--path DIR] [--layers LAYERS]
 *
 *   --layers: Comma-separated list from highest to lowest layer.
 *             Example: "routes,controllers,services,models,utils"
 *
 * Exit codes:
 *   0 — No violations
 *   1 — One or more import direction violations found
 */

const fs = require("fs");
const path = require("path");

const DEFAULT_PATH = ".";
const DEFAULT_LAYERS = "routes,controllers,services,models,utils";
const EXTENSIONS = new Set([".ts", ".tsx", ".js", ".jsx"]);
const SKIP_DIRS = new Set([
  "node_modules", ".git", "dist", "build", ".next", "coverage",
  "__pycache__", "venv", ".venv", "tests", "__tests__",
]);

// Matches: import ... from '...' and require('...')
const IMPORT_PATTERNS = [
  /import\s+.*?\s+from\s+['"]([^'"]+)['"]/g,
  /import\s*\(\s*['"]([^'"]+)['"]\s*\)/g,
  /require\s*\(\s*['"]([^'"]+)['"]\s*\)/g,
];

function findSourceFiles(root) {
  const files = [];

  function walk(dir) {
    let entries;
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }

    for (const entry of entries) {
      if (SKIP_DIRS.has(entry.name)) continue;

      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile() && EXTENSIONS.has(path.extname(entry.name))) {
        files.push(fullPath);
      }
    }
  }

  walk(root);
  return files.sort();
}

function getLayer(filepath, layers) {
  const parts = filepath.split(path.sep);
  for (const layer of layers) {
    if (parts.includes(layer)) return layer;
  }
  return null;
}

function getImportedLayers(filepath, layers, content) {
  const results = [];
  const lines = content.split("\n");

  for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    const line = lines[lineIdx];

    for (const pattern of IMPORT_PATTERNS) {
      // Reset regex state
      pattern.lastIndex = 0;
      let match;
      while ((match = pattern.exec(line)) !== null) {
        const importPath = match[1];
        const parts = importPath.split("/");

        for (const part of parts) {
          if (layers.includes(part)) {
            results.push({ layer: part, line: lineIdx + 1 });
            break;
          }
        }
      }
    }
  }

  return results;
}

function checkImportDirection(filepath, layers) {
  const fileLayer = getLayer(filepath, layers);
  if (!fileLayer) return [];

  let content;
  try {
    content = fs.readFileSync(filepath, "utf-8");
  } catch {
    return [];
  }

  const fileLayerIndex = layers.indexOf(fileLayer);
  const imported = getImportedLayers(filepath, layers, content);
  const violations = [];

  for (const { layer: importedLayer, line } of imported) {
    const importedIndex = layers.indexOf(importedLayer);
    // Lower index = higher layer. Files should only import from
    // layers with higher index (lower in the stack).
    if (importedIndex < fileLayerIndex) {
      violations.push(
        [
          `VIOLATION: Import Direction`,
          `FILE: ${filepath}:${line}`,
          `RULE: Layer '${fileLayer}' must not import from higher layer '${importedLayer}'`,
          `WHY: Lower layers importing higher layers creates circular dependencies and couples implementation details to interfaces. The dependency arrow must always point downward.`,
          `FIX: Move the shared logic into a lower layer that both can import, or pass the dependency as a parameter (dependency injection).`,
          "",
        ].join("\n")
      );
    }
  }

  return violations;
}

function main() {
  const args = process.argv.slice(2);
  let rootPath = DEFAULT_PATH;
  let layersStr = DEFAULT_LAYERS;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--path" && args[i + 1]) {
      rootPath = args[i + 1];
      i++;
    } else if (args[i] === "--layers" && args[i + 1]) {
      layersStr = args[i + 1];
      i++;
    }
  }

  const layers = layersStr.split(",").map((s) => s.trim()).filter(Boolean);

  if (layers.length < 2) {
    console.error("Error: need at least 2 layers to check direction");
    process.exit(1);
  }

  if (!fs.existsSync(rootPath) || !fs.statSync(rootPath).isDirectory()) {
    console.error(`Error: ${rootPath} is not a directory`);
    process.exit(1);
  }

  const files = findSourceFiles(rootPath);
  const allViolations = [];

  for (const f of files) {
    const violations = checkImportDirection(f, layers);
    allViolations.push(...violations);
  }

  if (allViolations.length === 0) {
    console.log(
      `OK: All imports in ${files.length} files respect layer boundaries (${layers.join(" → ")})`
    );
    process.exit(0);
  }

  for (const v of allViolations) {
    console.log(v);
  }

  console.log(
    `FAILED: ${allViolations.length} import direction violation(s) found`
  );
  process.exit(1);
}

main();
