# AGENTS.md

This repository contains installable agent skills.

## Repository Overview

Skills are packaged instructions and helper scripts that extend AI coding
agents. Keep the repository compatible with the public agent-skills layout:

```text
skills/
  {skill-name}/
    SKILL.md
    scripts/
    references/
skills.sh.json
```

## Creating or Updating a Skill

- Put every skill in `skills/{skill-name}/`.
- Use kebab-case for skill directory names.
- Keep `SKILL.md` uppercase and use that exact filename.
- Include only `name` and `description` in `SKILL.md` frontmatter.
- Make descriptions specific enough to trigger the skill at the right time.
- Keep `SKILL.md` concise; move detailed material to `references/`.
- Put deterministic helper code in `scripts/`.
- Use cleanup traps for scripts that create temporary files.
- Prefer conservative security language; never claim a third-party repository is
  completely safe.

## Installation Documentation

Document public installation with:

```bash
npx skills add lukyapp/agent-skills --skill {skill-name}
```

Update `skills.sh.json` whenever adding or renaming skills.
