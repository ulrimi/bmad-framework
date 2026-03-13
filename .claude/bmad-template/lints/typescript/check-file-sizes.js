#!/usr/bin/env node
/**
 * Check that source files stay under a configurable line limit.
 *
 * Large files indicate mixed responsibilities. They are harder for agents
 * to reason about and more likely to cause merge conflicts.
 *
 * Usage:
 *   node lints/typescript/check-file-sizes.js [--max-lines N] [--path DIR]
 *
 * Exit codes:
 *   0 — No violations
 *   1 — One or more files exceed the limit
 */

const fs = require("fs");
const path = require("path");

const DEFAULT_MAX_LINES = 300;
const DEFAULT_PATH = ".";
const EXTENSIONS = new Set([".ts", ".tsx", ".js", ".jsx"]);
const SKIP_DIRS = new Set([
  "node_modules", ".git", "dist", "build", ".next", "coverage",
  "__pycache__", "venv", ".venv",
]);

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

function checkFileSize(filepath, maxLines) {
  let content;
  try {
    content = fs.readFileSync(filepath, "utf-8");
  } catch {
    return null;
  }

  const lineCount = content.split("\n").length;
  if (lineCount <= maxLines) return null;

  const stem = path.basename(filepath, path.extname(filepath));
  return [
    `VIOLATION: File Size Limit`,
    `FILE: ${filepath}:${lineCount}`,
    `RULE: Source files must be under ${maxLines} lines`,
    `WHY: Large files indicate mixed responsibilities. They are harder for agents to reason about and more likely to cause merge conflicts.`,
    `FIX: Extract related functions into a new module. Split by responsibility (e.g., ${stem}.core.ts, ${stem}.helpers.ts).`,
    "",
  ].join("\n");
}

function main() {
  const args = process.argv.slice(2);
  let maxLines = DEFAULT_MAX_LINES;
  let rootPath = DEFAULT_PATH;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--max-lines" && args[i + 1]) {
      const parsed = parseInt(args[i + 1], 10);
      if (!Number.isFinite(parsed) || parsed <= 0) {
        console.error(`Error: --max-lines requires a positive integer, got "${args[i + 1]}"`);
        process.exit(1);
      }
      maxLines = parsed;
      i++;
    } else if (args[i] === "--path" && args[i + 1]) {
      rootPath = args[i + 1];
      i++;
    }
  }

  if (!fs.existsSync(rootPath) || !fs.statSync(rootPath).isDirectory()) {
    console.error(`Error: ${rootPath} is not a directory`);
    process.exit(1);
  }

  const files = findSourceFiles(rootPath);
  const violations = [];

  for (const f of files) {
    const violation = checkFileSize(f, maxLines);
    if (violation) violations.push(violation);
  }

  if (violations.length === 0) {
    console.log(`OK: All ${files.length} files are under ${maxLines} lines`);
    process.exit(0);
  }

  for (const v of violations) {
    console.log(v);
  }

  console.log(`FAILED: ${violations.length} file(s) exceed ${maxLines} lines`);
  process.exit(1);
}

main();
