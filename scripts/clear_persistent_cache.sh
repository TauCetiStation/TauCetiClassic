#!/bin/bash

cd ../cache/persistent || exit

# find and remove cache files unused for 30+ days
find . -atime +30 -type f -print0 | while IFS= read -r -d '' file; do
	echo "Removing $file"
	rm "$file"
done
