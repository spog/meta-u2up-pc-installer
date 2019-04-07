SUMMARY = "Disk partition editing/resizing utility"
HOMEPAGE = "http://www.gnu.org/software/parted/parted.html"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b6fdc2ec7367311f970da8ef475e6fd1"
SECTION = "console/tools"
DEPENDS = "bash"
PR = "r1"

SRC_URI = " \
           file://LICENSE \
           file://u2up-pc-installer.sh \
           file://u2up-images \
"

do_patch () {
	cp -p ${WORKDIR}/LICENSE ${S}/
	cp -p ${WORKDIR}/u2up-pc-installer.sh ${S}/
}

do_install () {
	install -d ${D}/usr/bin
	install -m 0755 ${S}/u2up-pc-installer.sh ${D}/usr/bin/
	install -d ${D}/home/root/u2up-images
	install -m 0644 ${WORKDIR}/u2up-images/intel-corei7-64/systemd-bootx64.efi ${D}/home/root/u2up-images/bootx64.efi
	install -m 0644 ${WORKDIR}/u2up-images/intel-corei7-64/bzImage-intel-corei7-64.bin ${D}/home/root/u2up-images/
	install -m 0644 ${WORKDIR}/u2up-images/intel-corei7-64/modules-intel-corei7-64.tgz ${D}/home/root/u2up-images/
	install -m 0644 ${WORKDIR}/u2up-images/intel-corei7-64/microcode.cpio ${D}/home/root/u2up-images/
	install -m 0644 ${WORKDIR}/u2up-images/intel-corei7-64/u2up-hag-image-full-cmdline-intel-corei7-64.tar.gz ${D}/home/root/u2up-images/
}

FILES_${PN} += "home"

RDEPENDS_${PN} = "bash"

