# Agent Skills

A personal collection of agent skills, organized like
[vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills).

The first included skills cover repository i18n workflows and security review
for Codex/agent skills before installation.

This repository follows the public agent-skills layout:

- skills live under `skills/{skill-name}/`
- each skill has a required `SKILL.md`
- helper scripts live inside the skill folder
- `skills.sh.json` describes grouping metadata for skills.sh

## Available Skills

### repo-i18n

Guides agents to follow a repository's configured i18n architecture when
changing UI copy, locale JSON files, or `next-intl` usage.

Use when:

- adding or changing user-facing copy
- editing translation keys or locale JSON files
- working in a repo that uses `next-intl`
- preventing ad hoc component-level `copy` objects
- translating only source-locale keys changed in the git diff

### skill-auditor

Audits an agent skill repository or installation command for risky files,
scripts, package hooks, remote execution, secret access, and instructions that
attempt to hide behavior from the user.

Use when:

- reviewing `npx skills add <repo> --skill <name>`
- inspecting a third-party skill repository
- checking a `SKILL.md`, `AGENTS.md`, `package.json`, or install script
- producing a security recommendation before installing a skill

## Installation

Install the skill from this repository:

```bash
npx skills add lukyapp/agent-skills --skill lukyapp-repo-i18n
npx skills add lukyapp/agent-skills --skill lukyapp-skill-auditor
```

Or, with the full GitHub URL:

```bash
npx skills add https://github.com/lukyapp/agent-skills --skill lukyapp-repo-i18n
npx skills add https://github.com/lukyapp/agent-skills --skill lukyapp-skill-auditor
```

## Manual Audit Helper

The skill includes a helper script:

```bash
bash skills/skill-auditor/scripts/audit-skill.sh \
  'npx skills add vercel-labs/agent-skills --skill react-best-practices'
```

The script clones the target repository into a temporary directory, lists
critical files, scans for risky patterns, and prints JSON to stdout for agents
or automation. Progress messages go to stderr.

For a human-readable report:

```bash
bash skills/skill-auditor/scripts/audit-skill.sh --human \
  'npx skills add vercel-labs/agent-skills --skill react-best-practices'
```

## Skill Structure

```text
skills/
  repo-i18n/
    SKILL.md
    references/
      config.md
    scripts/
      i18n-diff-keys.mjs
  skill-auditor/
    SKILL.md
    scripts/
      audit-skill.sh
skills.sh.json
AGENTS.md
README.md
```

## License

MIT
