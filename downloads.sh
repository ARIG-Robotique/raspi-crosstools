#!/bin/bash

BUILD_TOOLS_DIR=build-tools
SOURCES_DIR=sources

function download() {
    local path=$1
    local url=$2
    local filename=$3

    if [ ! -d ${path} ]; then
        mkdir -p ${path}
    fi
    cd ${path}

    if [ ! -f ${filename} ]; then
        wget ${url} -O ${filename}
    else 
        echo " * Le fichier ${filename} existe déjà"
    fi
    cd ..
}

function download_and_extract() {
    local path=$1
    local url=$2
    local filename=$3
    local extension=$4
    local extract_args=${5:-xvf}

    download ${path} ${url} ${filename}.${extension} 
    
    cd ${path}  
    if [ ! -d ${filename} ]; then
        tar ${extract_args} ${filename}.${extension}
    else 
        echo " * Le fichier ${filename}.${extension} est déjà extrait"
    fi
    cd ..
}

function download_sysroot() {
    local sysroot_dir=$1
    local web_url=$2
    if [ ! -d ${BUILD_TOOLS_DIR}/${sysroot_dir} ]; then
        if [ "$(uname)" == "Darwin" ]; then
            open ${web_url} > /dev/null
        else 
            xdg-open ${web_url} > /dev/null
        fi
        DOWNLOAD_URL=$(zenity --entry --title="ARIG - Sysroot URL" --text="Saisissez l'url de download :")
        if [ "${?}" -ne 0 ] ; then
            echo "Opération annulé"
            exit 1
        fi
        download_and_extract ${BUILD_TOOLS_DIR} ${DOWNLOAD_URL} ${sysroot_dir} tar.gz xvzf
        cd ${BUILD_TOOLS_DIR}
        ./sysroot-relativelinks.py ${sysroot_dir}
        cd ..
    else 
        echo " * Le sysroot ${sysroot_dir} est déjà extrait"
    fi  
}

alias python=python3

echo "Récupération des build-tools Linux"
GCC_LINUX_AARCH_64_FILENAME=gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
GCC_LINUX_AARCH_64_EXTENSION=tar.xz
GCC_LINUX_AARCH_64_URL=https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/${GCC_LINUX_AARCH_64_FILENAME}.${GCC_LINUX_AARCH_64_EXTENSION}
download_and_extract ${BUILD_TOOLS_DIR} ${GCC_LINUX_AARCH_64_URL} ${GCC_LINUX_AARCH_64_FILENAME} ${GCC_LINUX_AARCH_64_EXTENSION}

echo "Récupération des build-tools MacOS (Apple Silicon)"
GCC_DARWIN_AARCH_64_FILENAME=arm-gnu-toolchain-14.2.rel1-darwin-arm64-aarch64-none-elf
GCC_DARWIN_AARCH_64_EXTENSION=tar.xz
GCC_DARWIN_AARCH_64_URL=https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/${GCC_DARWIN_AARCH_64_FILENAME}.${GCC_DARWIN_AARCH_64_EXTENSION}
download_and_extract ${BUILD_TOOLS_DIR} ${GCC_DARWIN_AARCH_64_URL} ${GCC_DARWIN_AARCH_64_FILENAME} ${GCC_DARWIN_AARCH_64_EXTENSION}

echo "Récupération script de restructuration des liens symboliques"
download ${BUILD_TOOLS_DIR} https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py sysroot-relativelinks.py
chmod +x ${BUILD_TOOLS_DIR}/sysroot-relativelinks.py

echo "Récupération des sysroots"
download_sysroot sysroot-2021-05-07-raspios-buster-aarch64 https://github.com/ARIG-Robotique/raspi-crosstools/packages/1251567?version=2021.05.07
download_sysroot sysroot-2022-01-28-raspios-bullseye-aarch64 https://github.com/ARIG-Robotique/raspi-crosstools/packages/1251567?version=2022.01.28

echo "Récupération des sources"
QT_EXTENSION=tar.xz
QT_FILENAME=qt-everywhere-src-5.15.2
QT_URL=https://download.qt.io/archive/qt/5.15/5.15.2/single/${QT_FILENAME}.${QT_EXTENSION}
download_and_extract ${SOURCES_DIR} ${QT_URL} ${QT_FILENAME} ${QT_EXTENSION}

QT_FILENAME=qt-everywhere-src-6.2.2
QT_URL=https://download.qt.io/archive/qt/6.2/6.2.2/single/${QT_FILENAME}.${QT_EXTENSION}
download_and_extract ${SOURCES_DIR} ${QT_URL} ${QT_FILENAME} ${QT_EXTENSION}
