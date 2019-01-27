#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $parent_path

cl=""
for var in "$@"
do
    cl+="$var "
done
echo "$cl" > ../test_merge.txt
