#!/bin/bash
#
# A dialog menu based u2up-pc-installer program
#
#set -xe

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
U2UP_CONF_DIR=${HOME}/u2up-images/conf
U2UP_KEYMAP_CONF_FILE=${U2UP_CONF_DIR}/u2up_keymap-conf
U2UP_TARGET_DISK_CONF_FILE=${U2UP_CONF_DIR}/u2up_target_disk-conf

if [ ! -d "${U2UP_CONF_DIR}" ]; then
	rm -rf $U2UP_CONF_DIR
	mkdir -p $U2UP_CONF_DIR
fi

display_result() {
	dialog \
		--title "$1" \
		--no-collapse \
		--msgbox "$result" 0 0
}

store_keymap_selection() {
	keymap=$1
	if [ -n "$keymap" ]; then
		loadkeys $keymap
		if [ $? -eq 0 ]; then
			echo "KEYMAP=$keymap" > /etc/vconsole.conf
			echo "KEYMAP_SET=$keymap" > ${U2UP_KEYMAP_CONF_FILE}
		else
			rm -f /etc/vconsole.conf
			rm -f ${U2UP_KEYMAP_CONF_FILE}
		fi
	fi
}

store_target_disk_selection() {
	disk=$1

	cat ${U2UP_TARGET_DISK_CONF_FILE} | grep -v "TARGET_DISK_SET=" > ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	if [ -n "$disk" ]; then
		echo "TARGET_DISK_SET=$disk" >> ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	fi
	mv ${U2UP_TARGET_DISK_CONF_FILE}_tmp ${U2UP_TARGET_DISK_CONF_FILE}
}

store_target_part_selection() {
	part=$1

	cat ${U2UP_TARGET_DISK_CONF_FILE} | grep -v "TARGET_PART_SET=" > ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	if [ -n "$part" ]; then
		echo "TARGET_PART_SET=$part" >> ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	fi
	mv ${U2UP_TARGET_DISK_CONF_FILE}_tmp ${U2UP_TARGET_DISK_CONF_FILE}
}

store_target_partsize_selection() {
	part=$(echo $@ | sed 's/RENAMED //' | sed 's/ .*//')
	declare -i part_size=$(echo $@ | sed 's/.*://')

	if [ $part_size -le 0 ]; then
		return
	fi
	case $part in
	Boot)
		var_TARGET_PARTSZ_SET=TARGET_BOOT_PARTSZ_SET
		var_TARGET_PARTSZ_CURRENT=TARGET_BOOT_PARTSZ_CURRENT
		;;
	RootA)
		var_TARGET_PARTSZ_SET=TARGET_ROOTA_PARTSZ_SET
		var_TARGET_PARTSZ_CURRENT=TARGET_ROOTA_PARTSZ_CURRENT
		;;
	RootB)
		var_TARGET_PARTSZ_SET=TARGET_ROOTB_PARTSZ_SET
		var_TARGET_PARTSZ_CURRENT=TARGET_ROOTB_PARTSZ_CURRENT
		;;
	Log)
		var_TARGET_PARTSZ_SET=TARGET_LOG_PARTSZ_SET
		var_TARGET_PARTSZ_CURRENT=TARGET_LOG_PARTSZ_CURRENT
		;;
	*)
		exit;
	esac

	cat ${U2UP_TARGET_DISK_CONF_FILE} | grep -v "${var_TARGET_PARTSZ_SET}=" > ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	echo "${var_TARGET_PARTSZ_SET}=$part_size" >> ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	mv ${U2UP_TARGET_DISK_CONF_FILE}_tmp ${U2UP_TARGET_DISK_CONF_FILE}
	echo "${var_TARGET_PARTSZ_CURRENT}=${part_size}"
}

display_keymap_submenu() {
	KEYMAP_CURRENT=$1
	menu=""

	for name in $(find /usr/share/keymaps | grep "gz" | sed 's%.*/%%' | sort); do
		temp="$(basename ${name} .map.gz)"
		menu="$menu $temp $temp "
	done
	exec 3>&1
	selection=$(dialog \
		--backtitle "U2UP installer setup" \
		--title "Keyboard mapping selection" \
		--clear \
		--no-tags \
		--default-item "$KEYMAP_CURRENT" \
		--cancel-label "Cancel" \
		--menu "Please select:" $HEIGHT $WIDTH 0 \
		${menu} \
	2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	case $exit_status in
	$DIALOG_CANCEL|$DIALOG_ESC)
		clear
		echo "Return from submenu."
		return 0
		;;
	esac

	store_keymap_selection $selection
}

display_target_disk_submenu() {
	TARGET_DISK_CURRENT=$1
	local radiolist=""
	local tag="start_tag"

	current_root=$(lsblk -r | grep " /$" | sed 's/[0-9].*//')
	radiolist=$(lsblk -ir -o NAME,SIZE,MODEL | grep -v $current_root | sed 's/x20//g' | sed 's/\\//g' | while read line; do
		set -- $line
		if [ -n "$1" ] && [ "$1" != "NAME" ] && [[ "$1" != "$tag"* ]]; then
			tag=$1
			shift
			if [ -n "$TARGET_DISK_CURRENT" ] && [ "$tag" == "$TARGET_DISK_CURRENT" ]; then
				echo -n "${tag}|"$@"|on|"
			else
				echo -n "${tag}|"$@"|off|"
			fi
		fi
	done)

	exec 3>&1
	selection=$(IFS='|'; \
	dialog \
		--backtitle "U2UP installer setup" \
		--title "Target disk selection" \
		--clear \
		--cancel-label "Cancel" \
		--radiolist "Please select:" $HEIGHT $WIDTH 0 \
		${radiolist} \
	2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	case $exit_status in
	$DIALOG_CANCEL|$DIALOG_ESC)
		clear
		echo "Return from submenu."
		return 0
		;;
	esac

	store_target_disk_selection $selection
}

display_target_part_submenu() {
	TARGET_DISK_CURRENT=$1
	TARGET_PART_CURRENT=$2
	local radiolist=""
	local tag="start_tag"

	radiolist=$(lsblk -ir -o NAME,SIZE,PARTUUID | grep -E "(${TARGET_DISK_CURRENT}2|${TARGET_DISK_CURRENT}3)" | while read line; do
		set -- $line
		if [ -n "$1" ] && [ "$1" != "NAME" ] && [[ "$1" != "$tag"* ]]; then
			tag=$1
			shift
			if [ -n "$TARGET_PART_CURRENT" ] && [ "$tag" == "$TARGET_PART_CURRENT" ]; then
				echo -n "${tag}|"$@"|on|"
			else
				echo -n "${tag}|"$@"|off|"
			fi
		fi
	done)

	if [ -z "$radiolist" ]; then
		store_target_part_selection sda2
		return 0
	fi

	exec 3>&1
	selection=$(IFS='|'; \
	dialog \
		--backtitle "U2UP installer setup" \
		--title "Target disk selection" \
		--clear \
		--cancel-label "Cancel" \
		--radiolist "Please select:" $HEIGHT $WIDTH 0 \
		${radiolist} \
	2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	case $exit_status in
	$DIALOG_CANCEL|$DIALOG_ESC)
		clear
		echo "Return from submenu."
		return 0
		;;
	esac

	store_target_part_selection $selection
}

display_target_partsizes_submenu() {
	TARGET_DISK_CURRENT=$1
	TARGET_BOOT_PARTSZ_CURRENT=${2:-2}
	TARGET_ROOTA_PARTSZ_CURRENT=${3:-20}
	TARGET_ROOTB_PARTSZ_CURRENT=${4:-20}
	TARGET_LOG_PARTSZ_CURRENT=${5:-5}

	while true; do
		exec 3>&1
		selection=$(IFS='|'; \
		dialog \
			--backtitle "U2UP installer setup" \
			--title "Target partitions" \
			--clear \
			--cancel-label "Cancel" \
			--cr-wrap \
			--inputmenu $(fdisk -l /dev/${TARGET_DISK_CURRENT})"\n\nPlease select:" $HEIGHT 0 15 \
			"Boot [/dev/${TARGET_DISK_CURRENT}1] (GiB):" ${TARGET_BOOT_PARTSZ_CURRENT} \
			"RootA [/dev/${TARGET_DISK_CURRENT}2] (GiB):" ${TARGET_ROOTA_PARTSZ_CURRENT} \
			"RootB [/dev/${TARGET_DISK_CURRENT}3] (GiB):" ${TARGET_ROOTB_PARTSZ_CURRENT} \
			"Log [/dev/${TARGET_DISK_CURRENT}4] (GiB):" ${TARGET_LOG_PARTSZ_CURRENT} \
		2>&1 1>&3)
		exit_status=$?
		exec 3>&-

		case $exit_status in
		$DIALOG_CANCEL|$DIALOG_ESC)
			clear
			echo "Return from submenu."
			return 0
			;;
		esac

		current_set="$(store_target_partsize_selection $selection)"
		if [ -n "$current_set" ]; then
			eval $current_set
		else
			current_set="$(store_target_partsize_selection "Boot :${TARGET_BOOT_PARTSZ_CURRENT}")"
			current_set="$(store_target_partsize_selection "RootA :${TARGET_ROOTA_PARTSZ_CURRENT}")"
			current_set="$(store_target_partsize_selection "RootB :${TARGET_ROOTB_PARTSZ_CURRENT}")"
			current_set="$(store_target_partsize_selection "Log :${TARGET_LOG_PARTSZ_CURRENT}")"
			break
		fi
	done
}

execute_target_install() {
	i=1
	while [ $i -le 10 ]; do
		((i++))
#		echo "alo alo, ..." >> u2up-images/log/install-log
		echo "alo alo, ..."
		sleep 1
	done
}

display_execute_target_install() {
	mkdir -p u2up-images/log
	touch u2up-images/log/install-log
	dialog \
		--backtitle "U2UP installer setup" \
		--title "Install" \
		--begin 10 10 \
		--tailboxbg u2up-images/log/install-log 5 100 \
		--and-widget \
		--begin 3 10 --msgbox "Press OK" 5 30
	execute_target_install
}

current_tag='1'
while true; do
	KEYMAP_SET=""
	TARGET_DISK_SET=""
	TARGET_PART_SET=""
	TARGET_BOOT_PARTSZ_SET=""
	TARGET_ROOTA_PARTSZ_SET=""
	TARGET_ROOTB_PARTSZ_SET=""
	TARGET_LOG_PARTSZ_SET=""

	if [ -f "${U2UP_KEYMAP_CONF_FILE}" ]; then
		source $U2UP_KEYMAP_CONF_FILE
	fi
	if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
		source $U2UP_TARGET_DISK_CONF_FILE
	fi
	exec 3>&1
	selection=$(dialog \
		--backtitle "U2UP installer setup" \
		--title "Menu" \
		--clear \
		--cancel-label "Exit" \
		--default-item $current_tag \
		--menu "Please select:" $HEIGHT $WIDTH 5 \
		"1" "Keyboard mapping [${KEYMAP_SET}]" \
		"2" "Target disk [${TARGET_DISK_SET}]" \
		"3" "Target partition [${TARGET_PART_SET}]" \
		"4" "Target partition sizes \
[\
1:${TARGET_BOOT_PARTSZ_SET}G, \
2:${TARGET_ROOTA_PARTSZ_SET}G, \
3:${TARGET_ROOTB_PARTSZ_SET}G, \
4:${TARGET_LOG_PARTSZ_SET}G\
]" \
		"5" "Install" \
	2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	case $exit_status in
	$DIALOG_CANCEL)
		clear
		echo "Program terminated."
		exit
		;;
	$DIALOG_ESC)
		clear
		echo "Program aborted." >&2
		exit 1
		;;
	esac

	current_tag=$selection
	case $selection in
	0)
		clear
		echo "Program terminated."
		;;
	1)
		display_keymap_submenu \
			$KEYMAP_SET
		;;
	2)
		display_target_disk_submenu \
			$TARGET_DISK_SET
		;;
	3)
		display_target_part_submenu \
			$TARGET_DISK_SET \
			$TARGET_PART_SET
		;;
	4)
		display_target_partsizes_submenu \
			$TARGET_DISK_SET \
			$TARGET_BOOT_PARTSZ_SET \
			$TARGET_ROOTA_PARTSZ_SET \
			$TARGET_ROOTB_PARTSZ_SET \
			$TARGET_LOG_PARTSZ_SET
		;;
	5)
		execute_target_install
		;;
	esac
done

