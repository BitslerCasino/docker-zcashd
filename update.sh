#!/usr/bin/env bash

VERSION=$1

if [ ! -z "$VERSION" ]; then
  echo "Missing version"
  exit;
fi

TEMPLATE=docker.template
rm -rf $VERSION
mkdir -p $VERSION
DOCKERFILE=$VERSION/Dockerfile
eval "echo \"$(cat "${TEMPLATE}")\"" > $DOCKERFILE

docker build -f ./$VERSION/Dockerfile -t bitsler/docker-zcashd:latest -t bitsler/docker-zcashd:$VERSION .

docker push bitsler/docker-zcashd:latest
docker push bitsler/docker-zcashd:$VERSION