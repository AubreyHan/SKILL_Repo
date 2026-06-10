#!/bin/bash

# Configuration
REPO_DIR="/Users/aubreyhan/.gemini/antigravity/skills"
cd "$REPO_DIR" || exit 1

# Ensure git pull doesn't require user input
git config pull.rebase false

while true; do
  # 1. Fetch remote changes silently
  git fetch -q origin main

  # 2. Check for local uncommitted changes
  if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
      # Local changes detected, wait 10 seconds before acting
      sleep 10
      
      # Add and commit
      git add .
      git commit -m "Auto sync from local $(date +'%Y-%m-%d %H:%M:%S')"
      
      # Pull first to avoid push conflicts if remote also changed simultaneously
      git pull -q origin main --no-edit
      
      # Push
      git push -q origin main
      
      # Restart loop to check again cleanly
      continue
  fi

  # 3. Check if remote is ahead
  LOCAL=$(git rev-parse @ 2>/dev/null)
  REMOTE=$(git rev-parse @{u} 2>/dev/null)

  if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
      # Since we already handled uncommitted changes above, the working tree is clean here.
      git pull -q origin main --no-edit
  fi

  # Poll interval
  sleep 5
done
