#!/bin/bash

BASE_DIR=$(pwd)

export FZF_DEFAULT_OPTS="--height 40% --reverse --border"

ROBOT=$(fzf < <(
        echo "Nerell"
        echo "Odin"
    )
)

BUILD_KIT=$(ls -d build-qt-* | fzf)
QT_VERSION=$(echo ${BUILD_KIT} | cut -d '-' -f3)

rsync -avz ${BASE_DIR}/${BUILD_KIT}/qt${QT_VERSION}-pi ${ROBOT}:
ssh ${ROBOT} "rm -Rf /home/pi/qt${QT_VERSION}"
ssh ${ROBOT} "mv /home/pi/qt${QT_VERSION}-pi /home/pi/qt${QT_VERSION}"