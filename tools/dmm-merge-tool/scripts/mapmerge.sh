#!/bin/sh
echo "Running Map Merger..."

command="java -jar tools/dmm-merge-tool/JTGMerge.jar"

$command merge --separator=NIX $1 $2 $3

if [ $? -ne 0 ]; then
    echo "Unable to automatically resolve map conflicts, please merge manually."
    exit 1
fi

echo "Map Merger successfully finished."
exit 0
