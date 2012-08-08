#!/bin/bash

cd $BUILT_PRODUCTS_DIR
mkdir tmp
cp -R MountainNotifierTemplate.app ./tmp/
cd tmp
zip -r MountainNotifierTemplate.zip .
mv MountainNotifierTemplate.zip $PROJECT_DIR
cd ..
rm -r tmp