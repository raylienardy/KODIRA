#!/usr/bin/env bash
# pre-commit hook
# Abort commit if sensitive files are staged and run format & analyze checks

# Get list of staged files
defaultIFS="$IFS"
IFS=$'\n'
staged=$(git diff --cached --name-only)
IFS="$defaultIFS"

# Patterns of sensitive files
patterns=('*.env' '.env' '*.jks' '*.keystore' 'local.properties' 'key.properties')

for file in $staged; do
  for pat in "${patterns[@]}"; do
    case "$file" in
      $pat) echo "Error: sensitive file staged -> $file"; exit 1 ;;
    esac
  done
done

# Run formatter
if ! (cd app && dart format .); then
  echo "Error: dart format failed"
  exit 1
fi

# Run analyzer
if ! (cd app && flutter analyze); then
  echo "Error: flutter analyze failed"
  exit 1
fi

exit 0
