#!/bin/bash

IMAGE_NAME=ghcr.io/arig-robotique/raspi-crosstools:local

docker build -t ghcr.io/arig-robotique/raspi-crosstools:local .
docker run -it --rm -e BUILD_IN_DOCKER=true -v $(pwd):/workdir -w /workdir ghcr.io/arig-robotique/raspi-crosstools:local bash
