#!/bin/bash
# Script to merge master into current branch.

echo "Merging master into current branch..."

if ! git merge upstream/master --no-edit ; then
    echo "Unable to merge automatically, please perform manual merge"
    echo "Aborting..."

    git merge --abort

    echo "Merge aborted!"
    exit 1
fi

echo "Merged successfully, performing push to remote..."

git push

if [ $? -ne 0 ]; then
    echo "Unable to push, please perform manual push"
    exit 1
fi

echo "Pushed successfully!"
echo "Done!"
