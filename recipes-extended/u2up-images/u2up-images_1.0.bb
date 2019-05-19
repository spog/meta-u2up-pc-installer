SUMMARY = "Adding target installlation images"
HOMEPAGE = "http://..."
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b6fdc2ec7367311f970da8ef475e6fd1"
SECTION = "console/tools"
PR = "r1"

SRC_URI = " \
           file://LICENSE \
"

do_patch () {
	mv ${WORKDIR}/LICENSE ${S}/
}

IMAGESDIR = "${HOME}/U2UP-YOCTO/u2up-yocto_homegw/u2up/build.intel-corei7-64_thud/tmp/deploy/images"

do_install () {
	install -d ${D}/var/lib/u2up-images
	install -m 0644 ${IMAGESDIR}/intel-corei7-64/systemd-bootx64.efi ${D}/var/lib/u2up-images/bootx64.efi
	install -m 0644 ${IMAGESDIR}/intel-corei7-64/bzImage-intel-corei7-64.bin ${D}/var/lib/u2up-images/
	install -m 0644 ${IMAGESDIR}/intel-corei7-64/modules-intel-corei7-64.tgz ${D}/var/lib/u2up-images/
	install -m 0644 ${IMAGESDIR}/intel-corei7-64/microcode.cpio ${D}/var/lib/u2up-images/
	install -m 0644 ${IMAGESDIR}/intel-corei7-64/u2up-homegw-image-full-cmdline-intel-corei7-64.tar.gz ${D}/var/lib/u2up-images/
}

FILES_${PN} += "var"

