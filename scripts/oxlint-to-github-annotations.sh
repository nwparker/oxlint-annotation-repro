#!/usr/bin/env bash
# Converts oxlint unix format output to GitHub Actions annotations
# Usage: oxlint -f unix [files...] 2>&1 | ./scripts/oxlint-to-github-annotations.sh [path-prefix]

prefix="${1:-}"
if [[ -n "$prefix" && "$prefix" != */ ]]; then
  prefix="${prefix}/"
fi

while IFS= read -r line; do
  # Match pattern: file:line:col: message [Severity/rule]
  if [[ $line =~ ^([^:]+):([0-9]+):([0-9]+):\ (.+)\ \[(Warning|Error)/([^\]]+)\]$ ]]; then
    file="${BASH_REMATCH[1]}"
    line_num="${BASH_REMATCH[2]}"
    col="${BASH_REMATCH[3]}"
    message="${BASH_REMATCH[4]}"
    severity="${BASH_REMATCH[5]}"
    rule="${BASH_REMATCH[6]}"

    if [[ -n "$prefix" && "$file" != "$prefix"* ]]; then
      file="${prefix}${file}"
    fi

    if [[ $severity == "Error" ]]; then
      echo "::error file=${file},line=${line_num},col=${col},title=${rule}::${message}"
    else
      echo "::warning file=${file},line=${line_num},col=${col},title=${rule}::${message}"
    fi

    if [[ "$rule" == "eslint(max-lines)" && -n "${OXLINT_PR_NUMBER:-}" && -n "${OXLINT_PR_HEAD_SHA:-}" && -n "${GITHUB_REPOSITORY:-}" ]]; then
      # Use -F so line is sent as an integer.
      gh api -X POST "repos/${GITHUB_REPOSITORY}/pulls/${OXLINT_PR_NUMBER}/comments" \
        -f body="[oxlint] ${rule}: ${message}" \
        -f commit_id="$OXLINT_PR_HEAD_SHA" \
        -f path="$file" \
        -F line="$line_num" \
        -f side="RIGHT" >/dev/null
    fi
  else
    echo "$line"
  fi
done
