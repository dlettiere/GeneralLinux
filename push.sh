#!/usr/bin/env bash
set -e

# Verify that the current directory is inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Error: Current directory is not a Git repository."
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "main")"

echo "=========================================="
echo " 📦 Git Status [Branch: ${CURRENT_BRANCH}]"
echo "=========================================="
git status

# Check if there are any modified, untracked, or deleted files
if [ -z "$(git status --porcelain)" ]; then
    echo ""
    echo "✅ Working tree is clean. Nothing to commit or push."
    exit 0
fi

echo ""
# Prompt for commit message if not passed as arguments
COMMIT_MSG="$*"
if [ -z "$COMMIT_MSG" ]; then
    read -r -p "Enter commit message: " COMMIT_MSG
fi

# Abort if the user provides an empty message
if [ -z "$COMMIT_MSG" ]; then
    echo "❌ Commit aborted: No commit message provided."
    exit 1
fi

echo ""
echo "🚀 Staging all changes (git add .)..."
git add .

echo "📝 Committing changes..."
git commit -m "$COMMIT_MSG"

echo "☁️  Pushing to remote (${CURRENT_BRANCH})..."
# Push to tracking upstream, or set upstream if not set yet
if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
    git push
else
    git push -u origin "$CURRENT_BRANCH"
fi

echo ""
echo "=========================================="
echo " ✅ Changes successfully pushed to remote!"
echo "=========================================="
