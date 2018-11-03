#!/bin/bash
# Script to rebase current branch on master.

echo "Rebasing current branch on master..."

if ! git rebase upstream/master ; then
	echo "Unable to rebase automatically, please perform rebase manually"
	echo "Aborting..."

	git rebase --abort

	echo "Rebase aborted!"
	exit 1
fi

echo "Rebased successfully, pushing to remote..."

git push -f

if [ $? -ne 0 ]; then
	echo "Unable to push, please perform manual operations"
	exit 1
fi

echo "Pushed successfully!"
