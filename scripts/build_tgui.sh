#!/bin/bash
set -euo pipefail

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION

cd tgui
chmod +x bin/tgui
bin/tgui --ci
cd ..
