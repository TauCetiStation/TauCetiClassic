#!/bin/bash
# Script for commits squashing and pushing them to remote branch.

if [ $(git rev-parse --abbrev-ref HEAD) == "master" ]; then
    echo "Current working branch is master. Please use separate branch to make changes. Aborted!"
    exit 1
fi

commitsNumber="$(git rev-list --count upstream/master..)"

if [ $commitsNumber -le 1 ]; then
    echo "No commits to squash. Aborted!"
    exit 1
fi

read -p "Provide message for new commit: " commitMessage
echo "Squashing $commitsNumber commits..."

# Actual squashing starts here.
git reset --soft HEAD~$commitsNumber
git commit -m $commitMessage
git push -f

echo "Done!"
