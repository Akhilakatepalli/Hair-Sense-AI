#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  Hair Sense AI — Auto Commit & Push Script
#  Runs after every successful Xcode build.
#  Auto-increments patch version, describes changes, commits & pushes.
# ─────────────────────────────────────────────────────────────

# Project root (one level up from scripts/)
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR" || exit 0

# ── Only run if inside a git repo ────────────────────────────
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "⚠️  Not a git repo. Skipping auto-commit."
  exit 0
fi

# ── Only run if there are actual changes ─────────────────────
if git diff --quiet && git diff --cached --quiet; then
  echo "✅ No changes to commit."
  exit 0
fi

# ── Read & increment version ──────────────────────────────────
VERSION_FILE="$PROJECT_DIR/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0.0" > "$VERSION_FILE"
fi

CURRENT=$(cat "$VERSION_FILE")
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3)

# Increment patch version
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION" > "$VERSION_FILE"

# ── Build a clear commit message from changed files ───────────
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
ALL_CHANGED=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$')

# Categorise what changed
VIEWS=$(echo "$ALL_CHANGED" | grep "Views/" | sed 's|Views/||g' | sed 's|\.swift||g' | tr '\n' ', ' | sed 's|, $||')
SERVICES=$(echo "$ALL_CHANGED" | grep "Services/" | sed 's|Services/||g' | sed 's|\.swift||g' | tr '\n' ', ' | sed 's|, $||')
MODELS=$(echo "$ALL_CHANGED" | grep "Models/" | sed 's|Models/||g' | sed 's|\.swift||g' | tr '\n' ', ' | sed 's|, $||')
VIEWMODELS=$(echo "$ALL_CHANGED" | grep "ViewModels/" | sed 's|ViewModels/||g' | sed 's|\.swift||g' | tr '\n' ', ' | sed 's|, $||')
OTHER=$(echo "$ALL_CHANGED" | grep -v "Views/\|Services/\|Models/\|ViewModels/" | tr '\n' ', ' | sed 's|, $||')

# Build description lines
DESCRIPTION=""
[ -n "$VIEWS" ]      && DESCRIPTION="${DESCRIPTION}\n- Views updated: ${VIEWS}"
[ -n "$SERVICES" ]   && DESCRIPTION="${DESCRIPTION}\n- Services updated: ${SERVICES}"
[ -n "$MODELS" ]     && DESCRIPTION="${DESCRIPTION}\n- Models updated: ${MODELS}"
[ -n "$VIEWMODELS" ] && DESCRIPTION="${DESCRIPTION}\n- ViewModels updated: ${VIEWMODELS}"
[ -n "$OTHER" ]      && DESCRIPTION="${DESCRIPTION}\n- Other files: ${OTHER}"

if [ -z "$DESCRIPTION" ]; then
  DESCRIPTION="\n- General updates and improvements"
fi

# ── Stage all changes ─────────────────────────────────────────
git add -A

# ── Commit ────────────────────────────────────────────────────
COMMIT_MSG="v${NEW_VERSION} — Build update$(echo -e "$DESCRIPTION")

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

git commit -m "$COMMIT_MSG"

# ── Push ──────────────────────────────────────────────────────
git push origin main

echo ""
echo "🚀 Hair Sense AI v${NEW_VERSION} committed and pushed to GitHub!"
