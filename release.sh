#!/usr/bin/env bash

# this is used along side github-release. install it via go get github.com/aktau/github-release
VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Missing version"
  exit;
fi

github-release release \
    --user bitslercasino \
    --repo docker-zcashd \
    --tag v$VERSION \
    --name "v$VERSION Stable Release" \
    --description "ZCash"

github-release upload \
    --user bitslercasino \
    --repo docker-zcashd \
    --tag v$VERSION \
    --name "zcash_install.sh" \
    --file zcash_install.sh

github-release upload \
    --user bitslercasino \
    --repo docker-zcashd \
    --tag v$VERSION \
    --name "zcash_utils.sh" \
    --file zcash_utils.sh

sed -i "s/docker-zcashd\/releases\/download\/.*\/zcash_install\.sh/docker-zcashd\/releases\/download\/v$VERSION\/zcash_install\.sh/g" README.md
sed -i "s/docker-zcashd\/releases\/download\/.*\/zcash_utils\.sh/docker-zcashd\/releases\/download\/v$VERSION\/zcash_utils\.sh/g" README.md