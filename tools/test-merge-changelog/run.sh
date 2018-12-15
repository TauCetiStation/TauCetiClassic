#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $parent_path
exec java -jar ../.groovy-shell/groovy-shell.jar script.groovy "$@"
