#!/bin/sh
set -e

if [ -f "~/BYOND/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/DreamMaker" ];
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  mkdir -p "~/BYOND/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}"
  cd "~/BYOND/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}"
  echo "Installing DreamMaker to $PWD"
  curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip -A "TauCetiStation/1.0 Continuous Integration"
  unzip -o byond.zip
  cd byond
  make here
fi
