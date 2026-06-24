#!/usr/bin/env node

import { readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptPath = fileURLToPath(import.meta.url);
const skillDir = path.resolve(path.dirname(scriptPath), "..");
const rulesDir = path.join(skillDir, "rules");
const outputPath = path.join(skillDir, "AGENTS.md");

const ruleFiles = (await readdir(rulesDir))
  .filter((file) => file.endsWith(".md"))
  .filter((file) => file !== "_template.md")
  .sort((a, b) => {
    if (a === "_sections.md") return -1;
    if (b === "_sections.md") return 1;
    return a.localeCompare(b);
  });

const sections = [];

sections.push(`# Luky App NestJS Boilerplate

This file is generated from \`rules/*.md\`.

Use these rules when creating, modifying, or reviewing NestJS API backend code
in projects that should follow Luky app boilerplate conventions.

Prefer the target repository's existing code first, then these rules when the
repository has no clear precedent.

## Workflow

1. Inspect \`package.json\`, \`src/main.ts\`, \`src/app.module.ts\`,
   \`prisma/schema.prisma\`, and nearby implementation patterns before editing.
2. Use installed dependencies and local helpers.
3. Keep code typed, direct, secure-by-default, and maintainable.
4. Add a new rule when a preference becomes recurring.`);

for (const file of ruleFiles) {
  const content = await readFile(path.join(rulesDir, file), "utf8");
  sections.push(content.trim());
}

await writeFile(outputPath, `${sections.join("\n\n")}\n`, "utf8");
