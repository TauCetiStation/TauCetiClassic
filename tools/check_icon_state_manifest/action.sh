#!/usr/bin/env bash
# check_icon_state_manifest.sh
# Verify the project contains icon_state listed in a manifest file

PROJECT_ROOT="$PWD"
cd tools/check_icon_state_manifest
npm ci
node_modules/.bin/coffee index.coffee "$PROJECT_ROOT"
