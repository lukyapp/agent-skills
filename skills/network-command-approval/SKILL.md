---
name: lukyapp-network-command-approval
description: Use before running shell commands in Codex when sandboxing or network access matters, especially dependency installation, package managers, downloads, git remote operations, Docker pulls/builds, language toolchains. Helps decide when to request escalated network approval before the first run instead of waiting for predictable sandbox failures.
---

# Network Command Approval

Decide whether a shell command is likely to need network access before running
it in a sandbox. If network access is likely, request escalation up front with a
clear approval question.

## Workflow

1. Check whether the command is very likely to contact the network.
2. If network access is likely, run the command with
   `sandbox_permissions: "require_escalated"` immediately.
3. Include a short `justification` that asks the user to allow the network or
   remote-system action.
4. Add a narrow `prefix_rule` only for repeatable non-destructive commands.
5. If an unclassified command fails with DNS, registry, index, package mirror,
   TLS, timeout, or connection errors, rerun it with escalation right away.

Do not spend time "letting it finish" for commands that are already known to be
network-bound. Ask for approval before the predictable sandbox failure.

## Very Likely Network Commands

Request approval before running these unless the user explicitly says to stay
offline or use only local cache:

- JavaScript package managers:
  `npm install`, `npm ci`, `npm update`, `npm audit`, `npm exec`, `npx`,
  `npm create`, `pnpm install`, `pnpm add`, `pnpm update`, `pnpm dlx`,
  `yarn install`, `yarn add`, `yarn dlx`, `bun install`, `bun add`,
  `bunx`, `corepack enable`, `corepack prepare`.
- Python package managers:
  `pip install`, `pip download`, `pipenv install`, `poetry install`,
  `poetry add`, `uv sync`, `uv add`, `uv pip install`, `conda install`.
- Other language ecosystems:
  `cargo fetch`, `cargo install`, first `cargo build` after dependency
  changes, `go get`, `go mod download`, `go mod tidy`, `bundle install`,
  `gem install`, `composer install`, `composer require`, `mix deps.get`,
  `dotnet restore`, `dotnet tool install`.
- Remote source control:
  `git clone`, `git fetch`, `git pull`, `git push`, `gh repo clone`,
  `gh pr checkout`, `gh pr create`, `gh pr checks`.
- Direct downloads and remote APIs:
  `curl`, `wget`, `http`, `scp`, `rsync` with a remote host, cloud CLIs,
  deploy CLIs, package registry CLIs.
- System package managers:
  `brew install`, `brew update`, `apt install`, `apt update`, `apk add`,
  `dnf install`, `yum install`.
- Containers:
  `docker pull`, `docker compose pull`, `docker build` when the Dockerfile
  pulls base images or installs packages, `docker compose up --build`.

## Usually Local Commands

Do not assume these need network access unless their project scripts clearly do:

- `npm run build`, `npm test`, `pnpm test`, `yarn lint`, `bun test`.
- `tsc`, `eslint`, `prettier`, `vitest`, `jest`, `pytest`, `ruff`.
- `git status`, `git diff`, `git log`, `git show`, `git branch`.
- File inspection commands such as `rg`, `sed`, `ls`, `find`, `cat`, `wc`.

If a local-looking script invokes installation, downloads, telemetry setup, a
remote database, a browser download, or a deploy target, reclassify it as likely
network access.

## Approval Pattern

Use concise approval text:

```text
Do you want to allow network access to install project dependencies?
```

Good escalation examples:

```json
{
  "cmd": "npm install",
  "sandbox_permissions": "require_escalated",
  "justification": "Do you want to allow network access to install npm dependencies?",
  "prefix_rule": ["npm", "install"]
}
```

```json
{
  "cmd": "git fetch origin",
  "sandbox_permissions": "require_escalated",
  "justification": "Do you want to allow network access to fetch from the remote repository?",
  "prefix_rule": ["git", "fetch"]
}
```

Do not add `prefix_rule` for broad arbitrary interpreters such as `python`,
`node`, or shells, and do not add it for destructive commands.

## Failure Handling

When a command was not classified as likely-network but fails with a network
symptom, treat the failure as the signal. Rerun with escalation immediately and
explain the reason in the approval prompt.

Prefer "I need approval because this command downloads dependencies" over
"I'll wait a bit longer" when the command is a package install or remote fetch.
