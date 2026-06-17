---
name: skill-auditor
description: Security auditor for Codex and agent skills. Use when reviewing skill installation commands such as "npx skills add <repo> --skill <name>", inspecting third-party skill repositories, checking SKILL.md or AGENTS.md files, analyzing package.json scripts, install hooks, shell scripts, GitHub workflows, or identifying potentially dangerous behavior before installation.
---

# Skill Auditor

Audit agent skills before installation and identify security risks. Treat every
result as a risk assessment, not a guarantee of safety.

## How It Works

1. Extract the repository URL or GitHub shorthand and the target skill name.
2. Determine whether the repository is official, known, or third-party.
3. Inspect critical files:
    - SKILL.md
    - AGENTS.md
    - package.json
    - package-lock.json, pnpm-lock.yaml, yarn.lock
    - scripts/
    - install.sh
    - .github/workflows/
4. Search for risky patterns:
    - `.env`, secrets, tokens, API keys
    - `curl`, `wget`, `fetch`
    - `rm -rf`, `sudo`, `chmod`
    - `child_process`, `exec`, `spawn`
    - `preinstall`, `postinstall`
    - `git push`
    - hidden behavior, silent exfiltration, or instructions to ignore users

## Usage

Run the bundled helper script when the user provides an install command:

```bash
bash skills/skill-auditor/scripts/audit-skill.sh \
  'npx skills add <repo-or-url> --skill <skill-name>'
```

The repository can be a full GitHub URL or a shorthand such as
`vercel-labs/agent-skills`.

The script writes progress messages to stderr and machine-readable JSON to
stdout. Use `--human` only when a plain text report is more useful:

```bash
bash skills/skill-auditor/scripts/audit-skill.sh --human \
  'npx skills add <repo-or-url> --skill <skill-name>'
```

## Output

Parse the JSON output and return results in this format:

```text
Verdict: OK / Prudence / Risque
Reasons:
- ...
Local verification commands:
- ...
Final recommendation:
...
```

The JSON schema is stable for automation:

```json
{
  "schema_version": "1.0",
  "repository": "owner/repo",
  "skill": "skill-name",
  "target_found": true,
  "scanned_paths": ["skills/skill-name"],
  "critical_files": ["./skills/skill-name/SKILL.md"],
  "findings": [
    { "file": "...", "line": 1, "match": "...", "severity": "warning" }
  ],
  "summary": {
    "critical_findings": 0,
    "warning_findings": 1,
    "total_findings": 1
  },
  "verdict": "Prudence",
  "recommendation": "..."
}
```

Use `OK` only when no obvious risk indicators are found and the source is
trusted or well understood. Use `Prudence` for third-party repositories, network
access, package hooks, or unclear behavior. Use `Risque` for destructive
commands, secret exfiltration, hidden actions, or instructions that bypass user
control.

## Troubleshooting

- If `git clone` fails, ask the user to confirm repository access and network
  permissions.
- If the target skill is missing, inspect the repository structure manually.
- If the helper script flags a pattern, quote the relevant file path and line
  number before recommending installation.

Never claim a repository is completely safe. Always recommend manual review
before installation.
