#!/bin/bash
#
# The "u2up-homegw-pc-installer" Wic image build script
#
# Copyright (C) 2019 Samo Pogacnik <samo_pogacnik@t-2.net>
# All rights reserved.
#
# This file is provided under the terms of the BSD 3-Clause license,
# available in the LICENSE file of the "meta-u2up-pc-installer" software project.
#
#set -x
#set -e

function usage_help ()
{
	echo "Usage: "$(basename  $0)" {path_to_homegw_images}"
	echo
	return
}

pre="$(basename  $0): "
#INSTALLER_IMAGE_NAME="$(basename  $0 | sed -e 's/^[^_]*_//' | sed -e 's/_.*//')"
INSTALLER_IMAGE_NAME="u2up-homegw-pc-installer"
echo "Building '${INSTALLER_IMAGE_NAME}' image..."

HOMEGW_IMAGES_PATH=""

while [[ $# > 0 ]]
do
	case $1 in
	*)
		if [ -z "$HOMEGW_IMAGES_PATH" ]; then
			HOMEGW_IMAGES_PATH=$1
		else
			echo $pre"ERROR - Unknown option: "$1
			echo
			usage_help
			exit 1
		fi
		;;
	esac
	shift # to the next token, if any
done

if [ -z "$HOMEGW_IMAGES_PATH" ]; then
	echo $pre"ERROR - Missing path to homegw images!"
	echo
	usage_help
	exit 1
fi

HOMEGW_IMAGESDIR="$(realpath $HOMEGW_IMAGES_PATH)"
if [ ! -d "$HOMEGW_IMAGESDIR" ]; then
	echo $pre"ERROR - '${HOMEGW_IMAGES_PATH}' - not a directory!"
	echo
	usage_help
	exit 1
fi

function check_image ()
{
	if [ ! -e "${HOMEGW_IMAGESDIR}/${1}" ]; then
		echo $pre"ERROR - '${HOMEGW_IMAGESDIR}/${1}' - not available!"
		echo
		usage_help
		exit 1
	fi
}

check_image systemd-bootx64.efi
check_image bzImage-intel-corei7-64.bin
check_image modules-intel-corei7-64.tgz
check_image microcode.cpio
check_image u2up-homegw-image-full-cmdline-intel-corei7-64.tar.gz

function rootfs_u2up_images_prepare ()
{
	echo $pre"Called ${FUNCNAME[0]}()..."
	set -e
	rm -rf ${ROOTFS_IMAGE_DIR}/u2up-images-rootfs
##	mkdir -p ${ROOTFS_IMAGE_DIR}/u2up-images-rootfs
##	cd ${ROOTFS_IMAGE_DIR}/u2up-images-rootfs
##	tar xzf ${BUILDDIR}/tmp/deploy/images/intel-corei7-64/u2up-pc-installer-image-full-cmdline-intel-corei7-64.tar.gz
##	cd -
	cp -a ${ROOTFS_IMAGE_DIR}/rootfs ${ROOTFS_IMAGE_DIR}/u2up-images-rootfs
	set +e
	ROOTFSDIR="${ROOTFS_IMAGE_DIR}/u2up-images-rootfs"
	if [ ! -d "${ROOTFSDIR}/var/lib" ]; then
		echo $pre"ERROR - '${ROOTFSDIR}' - does not look like a rootfs directory!"
		echo
		exit 1
	fi
	rm -rf ${ROOTFSDIR}/var/lib/u2up-images
	install -d ${ROOTFSDIR}/var/lib/u2up-images
	echo " - adding: u2up-pc-installer.tgz"
	install -m 0644 ${HOMEGW_IMAGESDIR}/u2up-pc-installer.tgz ${ROOTFSDIR}/var/lib/u2up-images/
	echo " - adding: u2up-homegw-bundle.tar.sha256"
	install -m 0644 ${HOMEGW_IMAGESDIR}/u2up-homegw-bundle.tar.sha256 ${ROOTFSDIR}/var/lib/u2up-images/
	echo " - adding: u2up-homegw-bundle.tar"
	install -m 0644 ${HOMEGW_IMAGESDIR}/u2up-homegw-bundle.tar ${ROOTFSDIR}/var/lib/u2up-images/
	echo
}

function build_image_wic ()
{
	echo $pre"Called ${FUNCNAME[0]}()..."
	out="${BUILDDIR}/${INSTALLER_IMAGE_NAME}"
	wks="${BUILDDIR}/../meta-u2up-pc-installer/scripts/u2up-pc-installer-image-full-cmdline.wks"
	if [ ! -e "$wks" ]; then
		echo $pre"ERROR - kickstart file '${wks}' - not available!"
		echo
		exit 1
	fi

	set -e
	wic create "$wks" -o "$out/" \
		--rootfs-dir "${ROOTFS_IMAGE_DIR}/u2up-images-rootfs" \
		--bootimg-dir "${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/share" \
		--kernel-dir "${BUILDDIR}/tmp/deploy/images/intel-corei7-64" \
		--native-sysroot "${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native"

	mv "$out/$(basename "${wks%.wks}")"*.direct "$out.wic"
	rm -rf "$out/"

	bmaptool create ${INSTALLER_IMAGE_NAME}.wic -o ${INSTALLER_IMAGE_NAME}.wic.bmap
}

ROOTFS_IMAGE_DIR="${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0"
rootfs_u2up_images_prepare
build_image_wic

