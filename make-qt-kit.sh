#!/bin/bash

BASE_DIR=$(pwd)

export FZF_DEFAULT_OPTS="--height 40% --reverse --border"

./downloads.sh

echo "Selection de la Raspeberry PI"
RASPI=$(fzf < <(
        echo "4"
    )
)

echo "Architecture CPU de la Raspeberry PI"
ARCH=$(fzf < <(
        echo "aarch64"
    )
)
NB_BITS="32"
if [ "${ARCH}" == "aarch64" ]; then
    NB_BITS="64"
fi

echo "Qt version"
QT_VERSION=$(fzf < <(
        echo "5.15.2"
        echo "6.2.2" 
    )
)

echo "Sysroot"
SYSROOT=$(fzf < <(
        echo "sysroot-2021-05-07-raspios-buster"
        echo "sysroot-2022-01-28-raspios-bullseye" 
    )
)
SYSROOT="${SYSROOT}-${ARCH}"

BUILD_PLATFORM="Native"
if [ -z "${BUILD_IN_DOCKER}" ]; then
    BUILD_PLATFORM="Docker"
fi

DIR_NAME=build-qt-${QT_VERSION}-raspi${RASPI}-${ARCH}-${SYSROOT}
echo ""
echo "Build OS       : $(uname -s)"
echo "Build platform : ${BUILD_PLATFORM}"
echo "Raspberry PI   : ${RASPI} - ${ARCH}"
echo "Sysroot        : ${SYSROOT}"
echo "QT Version     : ${QT_VERSION}"
echo "Build dir      : ${DIR_NAME}"
echo ""
echo "Continue ? (y/n)"
read CONTINUE
if [ "${CONTINUE}" != "y" ]; then
    exit 1
fi

mkdir -p ${BASE_DIR}/${DIR_NAME}/build
cd ${DIR_NAME}

if [ ! -d qt-everywhere-src-${QT_VERSION} ] ; then
    rsync -a --info=progress2 --no-i-r ${BASE_DIR}/sources/qt-everywhere-src-${QT_VERSION} .
fi

PATCH_FILE=arig-qt-${QT_VERSION}-pi${RASPI}-${ARCH}.patch
if [ ! -f ${PATCH_FILE} ] ; then
    cp -vf ../patches/${PATCH_FILE} .
    cd qt-everywhere-src-${QT_VERSION}
    echo "Apply patch ${PATCH_FILE}"
    patch -s -p0 < ../${PATCH_FILE}
fi

DEVICE=linux-rasp-pi${RASPI}-v3d-g++
if [ "${ARCH}" == "aarch64" ]; then
    DEVICE=linux-rasp-pi${RASPI}-64-v3d-g++
fi

GCC_CROSS_COMPILE=${BASE_DIR}/build-tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
if [ "$(uname -s)" == "Darwin" ]; then
    GCC_CROSS_COMPILE=${BASE_DIR}/build-tools/arm-gnu-toolchain-14.2.rel1-darwin-arm64-aarch64-none-elf/bin/aarch64-none-elf-
fi
if [ "${BUILD_PLATFORM}" == "Docker" ]; then
    GCC_CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
fi

cd ${BASE_DIR}/${DIR_NAME}/build
../qt-everywhere-src-${QT_VERSION}/configure -release -opengl es2 -eglfs -device ${DEVICE} -device-option CROSS_COMPILE=${GCC_CROSS_COMPILE} -sysroot ${BASE_DIR}/build-tools/${SYSROOT} -prefix /home/pi/qt${QT_VERSION} -extprefix ${BASE_DIR}/${DIR_NAME}/qt${QT_VERSION}-pi -hostprefix ${BASE_DIR}/${DIR_NAME}/qt${QT_VERSION}-host -opensource -confirm-license -skip qtscript -skip qtwayland -skip qtwebengine -nomake tests -make libs -pkg-config -no-use-gold-linker -v -recheck
make -j4
make install