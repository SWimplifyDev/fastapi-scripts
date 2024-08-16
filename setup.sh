#!/bin/bash
# Script version: 1.0

# Prompt the user
read -p "If you are using a .env file to storage secrets, please make sure it is on your project folder before running this script. Continue? (y/n): " choice

# Check the user's response
case "$choice" in 
  y|Y ) echo "Continuing...";;
  n|N ) echo "Exiting script."; exit 1;;
  * ) echo "Invalid input. Exiting script."; exit 1;;
esac

# Prompt the user for the repository URL
read -p "Enter the repository URL: " REPO_URL

# Extract REPO_NAME using parameter expansion
REPO_NAME=$(basename -s .git "$REPO_URL")

# Install Software
sudo apt update
sudo apt upgrade -y
sudo apt install python3 python3-pip python3-venv -y

# Clone repository
git clone "$REPO_URL"

# Navigate into the project folder
cd $REPO_NAME

# Create a virtual environment and activate it
python3 -m venv .venv
source .venv/bin/activate

# Install app requirements
pip install -r requirements.txt

# Run fastapi webserver
fastapi run