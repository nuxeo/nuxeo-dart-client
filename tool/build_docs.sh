#!/bin/bash
docgen --no-include-sdk --no-include-dependent-packages --exclude-lib=nuxeo_rest_client --exclude-lib=nuxeo_automation_client --compile .

pushd dartdoc-viewer/client/out/web/

# Cleanup packages
# delete the symlinks
find . -name "packages" -type l -delete
mkdir packages
cp -R ../packages/polymer packages
cp -R ../packages/web_components packages
cp -R ../packages/dartdoc_viewer packages
# Remove the unnecessary dart files
find . -name "*.dart" -type f -delete

# Replace the title
sed -i 's/Dart API Reference/Dart Nuxeo Client Library/g' index.html

# Overwrite some resources (logo, favicon, etc..)
cp ../../../../resource/* static

popd

# Clone gh-pages
git clone git@github.com:nelsonsilva/nuxeo-dart-client.git gh-pages
pushd gh-pages
git checkout -t origin/gh-pages

# Out with the old in with the new
rm -rf *
cp -r ../dartdoc-viewer/client/out/web/* .
# Add and commit
git add -A
git commit -m "Updated docs"
git push
popd

rm -rf gh-pages