#!/bin/bash -eux

[[ -z "${OPENHAB_VERSION:-}" ]] && echo "OPENHAB_VERSION is not set!" && exit 1

# OpenJDK
OPENJDK_DOWNLOAD_URL_X64="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9.1%2B1/OpenJDK11U-jre_x64_linux_hotspot_11.0.9.1_1.tar.gz"
OPENJDK_DOWNLOAD_FILENAME_X64="$(basename ${OPENJDK_DOWNLOAD_URL_X64})"
OPENJDK_DOWNLOAD_SHA256_X64="73ce5ce03d2efb097b561ae894903cdab06b8d58fbc2697a5abe44ccd8ecc2e5"

OPENJDK_DOWNLOAD_URL_ARM="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9.1%2B1/OpenJDK11U-jre_arm_linux_hotspot_11.0.9.1_1.tar.gz"
OPENJDK_DOWNLOAD_FILENAME_ARM="$(basename ${OPENJDK_DOWNLOAD_URL_ARM})"
OPENJDK_DOWNLOAD_SHA256_ARM="11628830c3c912edd10b91620ef0b9566640c5ea46439f1d028f3ebd98682dbb"

# OpenHAB
OPENHAB_DOWNLOAD_URLBASE='https://dl.bintray.com/openhab/mvn/org/openhab/distro/openhab'
OPENHAB_RELEASE="2.5.11"
OPENHAB_DOWNLOAD_URL="https://dl.bintray.com/openhab/mvn/org/openhab/distro/openhab/${OPENHAB_RELEASE}/openhab-${OPENHAB_RELEASE}.zip"
OPENHAB_DOWNLOAD_FILENAME="$(basename ${OPENHAB_DOWNLOAD_URL})"

# Ensure empty build directory
DL_DIR=./dl
BUILD_DIR=./build
mkdir -p $DL_DIR
mkdir -p $BUILD_DIR
rm -rfv $BUILD_DIR/*

# Java X64: Download
[[ -e "${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_X64}" ]] || wget -nv --no-clobber --no-hsts --no-check-certificate --output-document=${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_X64} ${OPENJDK_DOWNLOAD_URL_X64}
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Downloading Java failed with code $returncode."
    exit 1
fi

# Java X64: Verify
echo "${OPENJDK_DOWNLOAD_SHA256_X64} ${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_X64}" | sha256sum --check --status
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Verifying Java failed with code $returncode."
    exit 1
fi

# Java X64: Unpack
mkdir -p ${BUILD_DIR}/OpenJDK_X64
tar --strip-components=1 --directory=${BUILD_DIR}/OpenJDK_X64 -xvzf ${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_X64}
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Installation of OpenJDK with code $returncode failed."
    exit 1;
fi

# Java X64: Linking
ln -s ./OpenJDK_X64 ${BUILD_DIR}/OpenJDK_x86_64

# Java ARM: Download
[[ -e "${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_ARM}" ]] || wget -nv --no-clobber --no-hsts --no-check-certificate --output-document=${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_ARM} ${OPENJDK_DOWNLOAD_URL_ARM}
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Downloading Java failed with code $returncode."
    exit 1
fi

# Java ARM: Verify
echo "${OPENJDK_DOWNLOAD_SHA256_ARM} ${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_ARM}" | sha256sum --check --status
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Verifying Java failed with code $returncode."
    exit 1
fi

# Java ARM: Unpack
mkdir -p ${BUILD_DIR}/OpenJDK_ARM
tar --strip-components=1 --directory=${BUILD_DIR}/OpenJDK_ARM -xvzf ${DL_DIR}/${OPENJDK_DOWNLOAD_FILENAME_ARM}
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Installation of OpenJDK with code $returncode failed."
    exit 1;
fi

# Java ARM: Linking


# Downloading openHAB
[[ -e "${DL_DIR}/${OPENHAB_DOWNLOAD_FILENAME}" ]] || wget -nv --no-clobber --no-hsts --no-check-certificate --output-document=${DL_DIR}/${OPENHAB_DOWNLOAD_FILENAME} ${OPENHAB_DOWNLOAD_URL}
returncode=$?
if [[ $returncode != 0 ]]; then
    echo " Downloading openHAB failed with code $returncode."
    exit 1
fi

# Extract openHAB
mkdir -p ${BUILD_DIR}/openHAB

if [ -e $(which 7z) ]; then
    7z x ${DL_DIR}/${OPENHAB_DOWNLOAD_FILENAME} -o${BUILD_DIR}/openHAB
    returncode=$?
else
    unzip ${DL_DIR}/${OPENHAB_DOWNLOAD_FILENAME} -d ${BUILD_DIR}/openHAB
    returncode=$?
fi

if [[ $returncode != 0 ]]; then
    echo " Installation of openHAB failed with code $returncode."
    exit 1;
fi

# Adding little UI
cp -rf ./ui ${BUILD_DIR}

# Adding helper script(s)
cp -rf ./helper ${BUILD_DIR}

tar --directory=${BUILD_DIR} -czvf ./package.tgz .

FILE_NAME=openHAB-${OPENHAB_VERSION}-syno-noarch-0.001.spk
echo ${FILE_NAME}

rm -f ${FILE_NAME}

tar cf ${FILE_NAME} \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    conf \
    scripts \
    package.tgz \
    INFO \
    LICENSE \
    NOTICE \
    PACKAGE_ICON_120.PNG \
    PACKAGE_ICON.PNG \
    WIZARD_UIFILES
