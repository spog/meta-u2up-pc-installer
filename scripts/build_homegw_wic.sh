#!/bin/sh

## Emit a useful diagnostic if something fails:
#bb_exit_handler() {
#    ret=$?
#    case $ret in
#    0)  ;;
#    *)  case $BASH_VERSION in
#        "") echo "WARNING: exit code $ret from a shell command.";;
#        *)  echo "WARNING: ${BASH_SOURCE[0]}:${BASH_LINENO[0]} exit $ret from '$BASH_COMMAND'";;
#        esac
#        exit $ret
#    esac
#}
#trap 'bb_exit_handler' 0
#set -e
#export AR="x86_64-u2up-linux-ar"
#export ARCH="x86"
#export AS="x86_64-u2up-linux-as  "
#export BUILD_AR="ar"
#export BUILD_AS="as "
#export BUILD_CC="gcc "
#export BUILD_CCLD="gcc "
#export BUILD_CFLAGS="-isystem/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/include -O2 -pipe"
#export BUILD_CPP="gcc  -E"
#export BUILD_CPPFLAGS="-isystem/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/include"
#export BUILD_CXX="g++ "
#export BUILD_CXXFLAGS="-isystem/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/include -O2 -pipe"
#export BUILD_FC="gfortran "
#export BUILD_LD="ld "
#export BUILD_LDFLAGS="-L/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/lib -L/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/lib -Wl,-rpath-link,/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/lib -Wl,-rpath-link,/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/lib -Wl,-rpath,/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/lib -Wl,-rpath,/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/lib -Wl,-O1 -Wl,--allow-shlib-undefined -Wl,--dynamic-linker=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/sysroots-uninative/x86_64-linux/lib/ld-linux-x86-64.so.2"
#export BUILD_NM="nm"
#export BUILD_RANLIB="ranlib"
#export BUILD_STRIP="strip"
#export CC="x86_64-u2up-linux-gcc  -m64 -march=nehalem -mtune=generic -mfpmath=sse -msse4.2 -fstack-protector-strong  -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot"
#export CCACHE_DIR="/home/samo/.ccache"
#export CCLD="x86_64-u2up-linux-gcc  -m64 -march=nehalem -mtune=generic -mfpmath=sse -msse4.2 -fstack-protector-strong  -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot"
#export CFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0=/usr/src/debug/u2up-pc-installer-image-full-cmdline/1.0-r0 -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot= -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native= "
#export CPP="x86_64-u2up-linux-gcc -E --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot  -m64 -march=nehalem -mtune=generic -mfpmath=sse -msse4.2 -fstack-protector-strong  -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security"
#export CPPFLAGS=""
#export CXX="x86_64-u2up-linux-g++  -m64 -march=nehalem -mtune=generic -mfpmath=sse -msse4.2 -fstack-protector-strong  -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot"
#export CXXFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0=/usr/src/debug/u2up-pc-installer-image-full-cmdline/1.0-r0 -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot= -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native=  -fvisibility-inlines-hidden"
#unset DISTRO
#export FC="x86_64-u2up-linux-gfortran  -m64 -march=nehalem -mtune=generic -mfpmath=sse -msse4.2 -fstack-protector-strong  -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot"
#export HOME="/home/samo"
#export LC_ALL="en_US.UTF-8"
#export LD="x86_64-u2up-linux-ld --sysroot=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot  "
#export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -fstack-protector-strong -Wl,-z,relro,-z,now"
#export LOGNAME="samo"
#unset MACHINE
#export MAKE="make"
#export NM="x86_64-u2up-linux-nm"
#export OBJCOPY="x86_64-u2up-linux-objcopy"
#export OBJDUMP="x86_64-u2up-linux-objdump"
#export PACKAGE_INSTALL="    packagegroup-core-boot     packagegroup-core-full-cmdline          strace     keymaps     u2up-images     u2up-pc-installer     dialog     dosfstools      run-postinsts psplash packagegroup-core-ssh-openssh"
#export PATH="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/bin/crossscripts:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/opt/u2up/2.6/sysroots/x86_64-u2upsdk-linux/usr/bin/crossscripts:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/bin/crossscripts:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/sysroots-uninative/x86_64-linux/usr/bin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/bin/python3-native:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/repos/poky_thud/scripts:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/bin/x86_64-u2up-linux:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/bin/crossscripts:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/sbin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/usr/bin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/sbin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native/bin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/repos/poky_thud/bitbake/bin:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/hosttools"
#export PKG_CONFIG_DIR="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/lib/pkgconfig"
#export PKG_CONFIG_DISABLE_UNINSTALLED="yes"
#export PKG_CONFIG_LIBDIR="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/lib/pkgconfig"
#export PKG_CONFIG_PATH="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/lib/pkgconfig:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/share/pkgconfig"
#export PKG_CONFIG_SYSROOT_DIR="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot"
#export PKG_CONFIG_SYSTEM_INCLUDE_PATH="/usr/include"
#export PKG_CONFIG_SYSTEM_LIBRARY_PATH="/lib:/usr/lib"
#export PSEUDO_DISABLED="0"
#export PSEUDO_LOCALSTATEDIR="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/pseudo/"
#export PSEUDO_NOSYMLINKEXP="1"
#export PSEUDO_PASSWD="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/rootfs:/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native"
#export PSEUDO_PREFIX="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/sysroots-components/x86_64/pseudo-native/usr"
#export RANLIB="x86_64-u2up-linux-ranlib"
#export READELF="x86_64-u2up-linux-readelf"
export ROOTFS_SIZE="818200"
#unset SHELL
#export STRINGS="x86_64-u2up-linux-strings"
#export STRIP="x86_64-u2up-linux-strip"
#unset TARGET_ARCH
#export TARGET_CFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0=/usr/src/debug/u2up-pc-installer-image-full-cmdline/1.0-r0 -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot= -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native= "
#export TARGET_CPPFLAGS=""
#export TARGET_CXXFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0=/usr/src/debug/u2up-pc-installer-image-full-cmdline/1.0-r0 -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot= -fdebug-prefix-map=/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native= "
#export TARGET_LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -fstack-protector-strong -Wl,-z,relro,-z,now"
#export TERM="xterm-256color"
#export TZ="UTC"
#export UBOOT_ARCH="x86"
#export USER="samo"
#export base_bindir="/bin"
#export base_libdir="/lib"
#export base_prefix=""
#export base_sbindir="/sbin"
#export bindir="/usr/bin"
#export datadir="/usr/share"
#export docdir="/usr/share/doc"
#export exec_prefix="/usr"
#export includedir="/usr/include"
#export infodir="/usr/share/info"
#export libdir="/usr/lib"
#export libexecdir="/usr/libexec"
#export localstatedir="/var"
#export mandir="/usr/share/man"
#export nonarch_base_libdir="/lib"
#export nonarch_libdir="/usr/lib"
#export oldincludedir="/usr/include"
#export prefix="/usr"
#export sbindir="/usr/sbin"
#export servicedir="/srv"
#export sharedstatedir="/com"
#export sysconfdir="/etc"
#export systemd_system_unitdir="/lib/systemd/system"
#export systemd_unitdir="/lib/systemd"
#export systemd_user_unitdir="/usr/lib/systemd/user"


do_image_wic() {
#		out="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/deploy-u2up-pc-installer-image-full-cmdline-image-complete/u2up-pc-installer-image-full-cmdline-intel-corei7-64-20190520160512"
	out="${BUILDDIR}/u2up-homegw"
	wks="${BUILDDIR}/../meta-u2up-pc-installer/scripts/u2up-pc-installer-image-full-cmdline.wks"
	if [ -z "$wks" ]; then
		bbfatal "No kickstart files from WKS_FILES were found: systemd-bootdisk-microcode.wks u2up-pc-installer-image-full-cmdline.wks. Please set WKS_FILE or WKS_FILES appropriately."
	fi

#	BUILDDIR="/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud" wic create "$wks" --vars "/home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/sysroots/intel-corei7-64/imgdata/" -e "u2up-pc-installer-image-full-cmdline" -o "$out/" 
#	wic create "$wks" --vars "${BUILDDIR}/../meta-u2up-pc-installer/scripts" -e "u2up-pc-installer-image-full-cmdline" -o "$out/" 
	wic create "$wks" -o "$out/" \
		--rootfs-dir "${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/rootfs" \
		--bootimg-dir "${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot/usr/share" \
		--kernel-dir "${BUILDDIR}/tmp/deploy/images/intel-corei7-64" \
		--native-sysroot "${BUILDDIR}/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/recipe-sysroot-native"

	mv "$out/$(basename "${wks%.wks}")"*.direct "$out.rootfs.wic"
	rm -rf "$out/"

#	cd /home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/deploy-u2up-pc-installer-image-full-cmdline-image-complete
#	bmaptool create u2up-pc-installer-image-full-cmdline-intel-corei7-64-20190520160512.rootfs.wic -o u2up-pc-installer-image-full-cmdline-intel-corei7-64-20190520160512.rootfs.wic.bmap
	bmaptool create u2up-homegw.rootfs.wic -o u2up-homegw.rootfs.wic.bmap
}

bbfatal() {
#	if [ -p /home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/temp/fifo.27119 ] ; then
#		printf "%b\0" "bbfatal $*" > /home/samo/U2UP-YOCTO/u2up-yocto_pc-installer/u2up/build.intel-corei7-64_thud/tmp/work/intel_corei7_64-u2up-linux/u2up-pc-installer-image-full-cmdline/1.0-r0/temp/fifo.27119
#	else
		echo "ERROR: $*"
#	fi
	exit 1
}

do_image_wic

## cleanup
#ret=$?
#trap '' 0
#exit $ret
