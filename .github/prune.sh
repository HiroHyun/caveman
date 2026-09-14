#!/bin/sh
# Prune the tree to the surface the Claude Code plugin loads.
#
# The plugin declares "source": "./" in .claude-plugin/marketplace.json, so the
# claude.ai-hosted validator inspects every file in the repository root. Two of
# its rules have rejected upstream's tree: a top-level bin/ directory, and a
# 50:1 cap on per-file compression ratio (tripped by engine/pixel/testdata
# fixtures). An allowlist keeps whatever upstream adds next out of scope.
#
# Idempotent. Safe to run on an already-pruned tree.
set -eu

KEEP='.git
.github
.claude-plugin
.gitattributes
.gitignore
src
commands
agents
skills
LICENSE
LICENSE.BSL
LICENSING.md
README.md'

for entry in * .[!.]* ..?*; do
  [ -e "$entry" ] || continue
  if printf '%s\n' "$KEEP" | grep -qxF -- "$entry"; then
    continue
  fi
  rm -rf -- "$entry"
done

# The URL in $schema answers HTTP 404, so the field resolves to no document.
sed -i '/"\$schema"[[:space:]]*:/d' .claude-plugin/marketplace.json
