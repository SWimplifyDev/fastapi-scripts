#!/bin/bash
# Script version: 1.0

# Prompt the user for the repository URL
read -p "Enter the repository URL: " REPO_URL

# Extract REPO_NAME using parameter expansion
REPO_NAME=$(basename -s .git "$REPO_URL")

# Define the path for the backup
BACKUP_DIR="backup/$(date +'%d_%m_%Y_%H%M')"

# Find backup dir, if not existed create one
if [ ! -d "backup" ]; then
    mkdir "backup"
    echo "Directory 'backup' created."
else
    echo "Directory 'backup' already exists."
fi

# Create a backup of the current repository directory
echo "Creating backup at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$REPO_NAME"/* "$BACKUP_DIR"

cd $REPO_NAME
# Update remote URL with token
git remote set-url origin "$REPO_URL"

# Fetch the latest changes from the remote
git fetch origin

# Hard reset the current branch to match the remote branch
git reset --hard origin/main

# Optional: Clean up untracked files
git clean -fd

echo "Repository updated successfully."

sudo systemctl restart fastapi.service