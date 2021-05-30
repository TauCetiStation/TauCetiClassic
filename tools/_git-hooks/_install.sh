#!/bin/sh
./pre_install.sh
echo "Installing dependencies..."
java -jar ../.groovy-shell/groovy-shell.jar install.groovy 2>/dev/null
read -rsp $'Press any key to continue...\n' -n 1 key
