#!/usr/bin/env bash
# install-hooks script – copies pre-commit hook into .git/hooks

# Ensure we are in a git repository
if [ ! -d ".git" ]; then
  echo ".git directory not found. Run from repository root."
  exit 1
fi

# Path to hook source and destination
src="$(dirname "$0")/pre-commit.sh"
 dest=".git/hooks/pre-commit"

# Copy hook
cp "$src" "$dest"
chmod +x "$dest"
# Ensure executable permission on Unix systems
if command -v git >/dev/null 2>&1; then
  git update-index --add --chmod=+x "$dest" >/dev/null 2>&1 || true
fi
