#!/bin/sh
echo "Installation in progress, please wait..."
java -jar ../.groovy-shell/groovy-shell.jar install.groovy 2>/dev/null
echo "Finished without errors."
read -rsp $'Press any key to continue...\n' -n 1 key
