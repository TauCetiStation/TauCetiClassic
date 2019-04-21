#!/bin/bash
# Script to configure upstream for sync.

repository="https://github.com/TauCetiStation/TauCetiClassic.git"
echo "Configuring upstream to ${repository}..."

git remote add upstream "$repository"
git fetch upstream

echo "Done!"
