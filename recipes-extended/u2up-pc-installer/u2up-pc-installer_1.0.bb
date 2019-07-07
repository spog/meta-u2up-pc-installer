SUMMARY = "U2UP PC target installation utility"
HOMEPAGE = "http://www...."
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b6fdc2ec7367311f970da8ef475e6fd1"
SECTION = "console/tools"
DEPENDS = "bash"
PR = "r1"

SRC_URI = " \
           file://u2up-pc-installer.sh \
           file://override.conf \
           file://noclear.conf \
           file://LICENSE \
"

do_patch () {
	cp -pf ${WORKDIR}/LICENSE ${S}/
	cp -pf ${WORKDIR}/noclear.conf ${S}/
	cp -pf ${WORKDIR}/override.conf ${S}/
	cp -pf ${WORKDIR}/u2up-pc-installer.sh ${S}/
}

do_install () {
	install -d ${D}/etc/profile.d
	install -m 0644 ${S}/u2up-pc-installer.sh ${D}/etc/profile.d/
	install -d ${D}/etc/systemd/system/getty@tty1.service.d
	install -m 0644 ${S}/noclear.conf ${D}/etc/systemd/system/getty@tty1.service.d/
	install -m 0644 ${S}/override.conf ${D}/etc/systemd/system/getty@tty1.service.d/
}

FILES_${PN} += "etc"

RDEPENDS_${PN} = "systemd bash tar"

