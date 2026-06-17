#!/usr/bin/env bash
set -euo pipefail

FORMAT="json"
if [[ "${1:-}" == "--human" || "${1:-}" == "--text" ]]; then
  FORMAT="text"
  shift
elif [[ "${1:-}" == "--json" ]]; then
  FORMAT="json"
  shift
fi

CMD="$*"

REPO="$(echo "$CMD" | sed -nE 's/.*npx skills add ([^ ]+).*/\1/p')"
SKILL="$(echo "$CMD" | sed -nE 's/.*--skill[= ]([^ ]+).*/\1/p')"

if [[ -z "${REPO}" || -z "${SKILL}" ]]; then
  echo "Usage: audit-skill.sh [--json|--human] 'npx skills add <url> --skill <name>'" >&2
  exit 1
fi

if [[ "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  URL="https://github.com/${REPO}.git"
else
  URL="$REPO"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Cloning $URL" >&2

git clone --depth 1 "$URL" "$TMP/repo" >/dev/null 2>&1
cd "$TMP/repo"

TARGET_FOUND=true
if [[ -d "skills/$SKILL" ]]; then
  TARGET="skills/$SKILL"
elif [[ -f "SKILL.md" ]]; then
  TARGET="."
else
  TARGET="."
  TARGET_FOUND=false
  echo "Warning: skills/$SKILL not found; scanning the full repository." >&2
fi

CRITICAL_FILES=()
while IFS= read -r file; do
  CRITICAL_FILES+=("$file")
done < <(find . -maxdepth 4 -type f \( \
  -name "SKILL.md" -o \
  -name "AGENTS.md" -o \
  -name "package.json" -o \
  -name "package-lock.json" -o \
  -name "pnpm-lock.yaml" -o \
  -name "yarn.lock" -o \
  -name "install.sh" -o \
  -path "./scripts/*" -o \
  -path "./skills/*/scripts/*" -o \
  -path "./.github/workflows/*" \
\) | sort)

SCAN_PATHS=("$TARGET")
for candidate in .github package.json package-lock.json pnpm-lock.yaml yarn.lock install.sh; do
  if [[ -e "$candidate" ]]; then
    SCAN_PATHS+=("$candidate")
  fi
done

RISK_PATTERN='(\.env|secret|token|api[_-]?key|curl|wget|fetch|rm -rf|sudo|chmod|child_process|exec\(|spawn\(|postinstall|preinstall|git push|ignore.*user|hide|silently|exfiltrat)'
CRITICAL_PATTERN='(rm -rf|sudo|child_process|exec\(|spawn\(|git push|postinstall|preinstall|exfiltrat)'

FINDINGS=()
while IFS= read -r finding; do
  FINDINGS+=("$finding")
done < <(grep -RInE --exclude-dir=.git "$RISK_PATTERN" "${SCAN_PATHS[@]}" || true)

if grep -RInE --exclude-dir=.git "$CRITICAL_PATTERN" "${SCAN_PATHS[@]}" >/dev/null; then
  VERDICT="Risque"
  RECOMMENDATION="Do not install before manually reviewing the flagged critical findings."
elif [[ "${#FINDINGS[@]}" -gt 0 || "$TARGET_FOUND" != "true" ]]; then
  VERDICT="Prudence"
  RECOMMENDATION="Review the flagged findings and repository ownership before installing."
else
  VERDICT="Prudence"
  RECOMMENDATION="No obvious risk indicators found, but manually review the source before installing."
fi

if [[ "$FORMAT" == "text" ]]; then
  echo "Commande: $CMD"
  echo "Repo: $REPO"
  echo "Clone URL: $URL"
  echo "Skill: $SKILL"
  echo "Target: $TARGET"
  echo "Target found: $TARGET_FOUND"
  echo
  echo "== Fichiers critiques =="
  if [[ "${#CRITICAL_FILES[@]}" -gt 0 ]]; then
    printf '%s\n' "${CRITICAL_FILES[@]}"
  fi
  echo
  echo "== Signaux dangereux =="
  if [[ "${#FINDINGS[@]}" -gt 0 ]]; then
    printf '%s\n' "${FINDINGS[@]}"
  fi
  echo
  echo "== Verdict automatique brut =="
  echo "Verdict: $VERDICT"
  echo "Recommendation: $RECOMMENDATION"
  exit 0
fi

CRITICAL_FILES_PATH="$TMP/critical-files.txt"
FINDINGS_PATH="$TMP/findings.txt"
SCAN_PATHS_PATH="$TMP/scanned-paths.txt"

if [[ "${#CRITICAL_FILES[@]}" -gt 0 ]]; then
  printf '%s\n' "${CRITICAL_FILES[@]}" >"$CRITICAL_FILES_PATH"
else
  : >"$CRITICAL_FILES_PATH"
fi

if [[ "${#FINDINGS[@]}" -gt 0 ]]; then
  printf '%s\n' "${FINDINGS[@]}" >"$FINDINGS_PATH"
else
  : >"$FINDINGS_PATH"
fi

if [[ "${#SCAN_PATHS[@]}" -gt 0 ]]; then
  printf '%s\n' "${SCAN_PATHS[@]}" >"$SCAN_PATHS_PATH"
else
  : >"$SCAN_PATHS_PATH"
fi

python3 - \
  "$CMD" \
  "$REPO" \
  "$URL" \
  "$SKILL" \
  "$TARGET" \
  "$TARGET_FOUND" \
  "$VERDICT" \
  "$RECOMMENDATION" \
  "$RISK_PATTERN" \
  "$CRITICAL_PATTERN" \
  "$CRITICAL_FILES_PATH" \
  "$FINDINGS_PATH" \
  "$SCAN_PATHS_PATH" <<'PY'
import json
import re
import sys
from pathlib import Path

(
    command,
    repository,
    clone_url,
    skill,
    target,
    target_found,
    verdict,
    recommendation,
    risk_pattern,
    critical_pattern,
    critical_files_path,
    findings_path,
    scan_paths_path,
) = sys.argv[1:]

findings = []

critical_files = [
    line
    for line in Path(critical_files_path).read_text(encoding="utf-8").splitlines()
    if line
]
scanned_paths = [
    line
    for line in Path(scan_paths_path).read_text(encoding="utf-8").splitlines()
    if line
]

for line in Path(findings_path).read_text(encoding="utf-8").splitlines():
    parts = line.split(":", 2)
    severity = "critical" if re.search(critical_pattern, line) else "warning"
    if len(parts) == 3 and parts[1].isdigit():
        findings.append(
            {
                "file": parts[0],
                "line": int(parts[1]),
                "match": parts[2],
                "severity": severity,
            }
        )
    elif line:
        findings.append(
            {"file": None, "line": None, "match": line, "severity": severity}
        )

critical_count = sum(1 for finding in findings if finding["severity"] == "critical")
warning_count = len(findings) - critical_count

result = {
    "schema_version": "1.0",
    "command": command,
    "repository": repository,
    "clone_url": clone_url,
    "skill": skill,
    "target": target,
    "target_found": target_found == "true",
    "scanned_paths": scanned_paths,
    "critical_files": critical_files,
    "findings": findings,
    "summary": {
        "critical_findings": critical_count,
        "warning_findings": warning_count,
        "total_findings": len(findings),
    },
    "verdict": verdict,
    "recommendation": recommendation,
    "local_verification_commands": [
        f"git clone --depth 1 {clone_url} skill-audit-repo",
        f"find skill-audit-repo -maxdepth 4 -type f | sort",
        f"grep -RInE --exclude-dir=.git {json.dumps(risk_pattern)} skill-audit-repo/{target}",
    ],
}

print(json.dumps(result, indent=2, sort_keys=True))
PY
