#!/bin/bash

IMAGE_NAME=ghcr.io/arig-robotique/raspi-crosstools:local

docker build -t ghcr.io/arig-robotique/raspi-crosstools:local .
docker run -it --rm -v $(pwd):/workdir -w /workdir ghcr.io/arig-robotique/raspi-crosstools:local /bin/bash make-qt-kit.sh
