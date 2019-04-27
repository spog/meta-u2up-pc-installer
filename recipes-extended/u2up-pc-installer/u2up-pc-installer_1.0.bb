SUMMARY = "U2UP PC target installation utility"
HOMEPAGE = "http://www...."
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b6fdc2ec7367311f970da8ef475e6fd1"
SECTION = "console/tools"
DEPENDS = "bash"
PR = "r1"

SRC_URI = " \
           file://LICENSE \
           file://u2up-install-bash-lib \
           file://u2up-pc-installer.sh \
"

do_patch () {
	mv ${WORKDIR}/LICENSE ${S}/
	mv ${WORKDIR}/u2up-install-bash-lib ${S}/
	mv ${WORKDIR}/u2up-pc-installer.sh ${S}/
}

do_install () {
	install -d ${D}/etc/u2up-conf.d
	install -d ${D}/lib/u2up
	install -m 0755 ${S}/u2up-install-bash-lib ${D}/lib/u2up/
	install -d ${D}/usr/bin
	install -m 0755 ${S}/u2up-pc-installer.sh ${D}/usr/bin/
}

FILES_${PN} += "etc lib usr"

RDEPENDS_${PN} = "bash u2up-images"

