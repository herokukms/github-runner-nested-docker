#!/bin/sh
echo "Building quietly it takes some times… Be patient"
BUILD_SHA=$(docker build . -q)
echo "Build ended, sha is $BUILD_SHA"
docker run -p 80:80 -v ./demo-entrypoint:/ext/entrypoint:ro -it $BUILD_SHA