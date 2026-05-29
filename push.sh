#!/bin/bash
# HeWork GitHub Push Script
# Usage: ./push.sh <GITHUB_TOKEN>

if [ -z "$1" ]; then
    echo "❌ Usage: ./push.sh <GITHUB_TOKEN>"
    echo ""
    echo "How to create a token:"
    echo "1. Go to https://github.com/settings/tokens/new"
    echo "2. Select 'Generate new token (classic)'"
    echo "3. Give it 'repo' scope"
    echo "4. Copy the token and run: ./push.sh ghp_your_token_here"
    exit 1
fi

TOKEN=$1
cd "$(dirname "$0")"

git remote set-url origin "https://jutsodev:${TOKEN}@github.com/jutsodev/hework.git"
git push -u origin main

echo "✅ Push complete!"
