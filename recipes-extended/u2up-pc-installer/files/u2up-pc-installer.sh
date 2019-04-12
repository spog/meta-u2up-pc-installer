#!/bin/bash
#
# A dialog menu based u2up-pc-installer program
#
#set -xe

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
U2UP_BACKTITLE="U2UP installer setup"
U2UP_CONF_DIR=${HOME}/u2up-images/conf
U2UP_KEYMAP_CONF_FILE=${U2UP_CONF_DIR}/u2up_keymap-conf
U2UP_TARGET_DISK_CONF_FILE=${U2UP_CONF_DIR}/u2up_target_disk-conf
U2UP_TARGET_DISK_SFDISK_BASH=${U2UP_CONF_DIR}/u2up_target_disk-sfdisk_bash
U2UP_TARGET_DISK_SFDISK_DUMP=${U2UP_CONF_DIR}/u2up_target_disk-sfdisk_dump

PART_TYPE_EFI="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
PART_TYPE_LINUX="0FC63DAF-8483-4772-8E79-3D69D8477DE4"

if [ ! -d "${U2UP_CONF_DIR}" ]; then
	rm -rf $U2UP_CONF_DIR
	mkdir -p $U2UP_CONF_DIR
fi

display_result() {
	dialog \
		--backtitle "${U2UP_BACKTITLE}" \
		--title "$1" \
		--no-collapse \
		--msgbox "$2" 6 75
}

display_msg() {
	dialog \
		--backtitle "${U2UP_BACKTITLE}" \
		--title "$1" \
		--cr-wrap \
		--no-collapse \
		--msgbox "$2" $3 75
}

display_yesno() {
	dialog \
		--backtitle "${U2UP_BACKTITLE}" \
		--title "$1" \
		--cr-wrap \
		--no-collapse \
		--yesno "$2" $3 75
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
	local var_target_partsz_set=""
	local var_target_partsz_current=""
	local part=$(echo $@ | sed 's/RENAMED //' | sed 's/ .*//')
	declare -i part_size=$(echo $@ | sed 's/.*://')

	if [ $part_size -le 0 ]; then
		return
	fi
	case $part in
	boot)
		var_target_partsz_set=TARGET_BOOT_PARTSZ_SET
		var_target_partsz_current=target_boot_partsz_current
		;;
	log)
		var_target_partsz_set=TARGET_LOG_PARTSZ_SET
		var_target_partsz_current=target_log_partsz_current
		;;
	rootA)
		var_target_partsz_set=TARGET_ROOTA_PARTSZ_SET
		var_target_partsz_current=target_rootA_partsz_current
		;;
	rootB)
		var_target_partsz_set=TARGET_ROOTB_PARTSZ_SET
		var_target_partsz_current=target_rootB_partsz_current
		;;
	*)
		exit;
	esac

	cat ${U2UP_TARGET_DISK_CONF_FILE} | grep -v "${var_target_partsz_set}=" > ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	echo "${var_target_partsz_set}=$part_size" >> ${U2UP_TARGET_DISK_CONF_FILE}_tmp
	mv ${U2UP_TARGET_DISK_CONF_FILE}_tmp ${U2UP_TARGET_DISK_CONF_FILE}
	echo "${var_target_partsz_current}=${part_size}"
}

display_keymap_submenu() {
	local keymap_current=$1
	menu=""

	for name in $(find /usr/share/keymaps | grep "gz" | sed 's%.*/%%' | sort); do
		temp="$(basename ${name} .map.gz)"
		menu="$menu $temp $temp "
	done
	exec 3>&1
	selection=$(dialog \
		--backtitle "${U2UP_BACKTITLE}" \
		--title "Keyboard mapping selection" \
		--clear \
		--no-tags \
		--default-item "$keymap_current" \
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
	local target_disk_current=$1
	local radiolist=""
	local tag="start_tag"

	current_root=$(lsblk -r | grep " /$" | sed 's/[0-9].*//')
	radiolist=$(lsblk -ir -o NAME,SIZE,MODEL | grep -v $current_root | sed 's/x20//g' | sed 's/\\//g' | while read line; do
		set -- $line
		if [ -n "$1" ] && [ "$1" != "NAME" ] && [[ "$1" != "$tag"* ]]; then
			tag=$1
			shift
			if [ -n "$target_disk_current" ] && [ "$tag" == "$target_disk_current" ]; then
				echo -n "${tag}|"$@"|on|"
			else
				echo -n "${tag}|"$@"|off|"
			fi
		fi
	done)

	exec 3>&1
	selection=$(IFS='|'; \
	dialog \
		--backtitle "${U2UP_BACKTITLE}" \
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
	local target_disk_current=$1
	local target_part_current=$2
	local radiolist=""
	local tag="start_tag"

	radiolist=$(lsblk -ir -o NAME,SIZE,PARTUUID | grep -E "(${target_disk_current}3|${target_disk_current}4)" | while read line; do
		set -- $line
		if [ -n "$1" ] && [ "$1" != "NAME" ] && [[ "$1" != "$tag"* ]]; then
			tag=$1
			shift
			if [ -n "$target_part_current" ] && [ "$tag" == "$target_part_current" ]; then
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
		--backtitle "${U2UP_BACKTITLE}" \
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

check_target_disk_set() {
	if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
		source $U2UP_TARGET_DISK_CONF_FILE
	else
		TARGET_DISK_SET=""
	fi
	if [ -z "$TARGET_DISK_SET" ]; then
		display_result "Target disk check" "Please select your target disk for the installation!"
		return 1
	fi
}

check_target_part_set() {
	if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
		source $U2UP_TARGET_DISK_CONF_FILE
	else
		TARGET_PART_SET=""
	fi
	if [ -z "$TARGET_PART_SET" ]; then
		display_result "Target partition check" "Please select your target partition for the installation!"
		return 1
	fi
}

check_target_part_sizes_set() {
	if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
		source $U2UP_TARGET_DISK_CONF_FILE
	else
		TARGET_BOOT_PARTSZ_SET=""
	fi
	if \
		[ -z "$TARGET_BOOT_PARTSZ_SET" ] || \
		[ -z "$TARGET_LOG_PARTSZ_SET" ] || \
		[ -z "$TARGET_ROOTA_PARTSZ_SET" ] || \
		[ -z "$TARGET_ROOTB_PARTSZ_SET" ];
	then
		display_result "Target partition sizes check" "Please set your target partition sizes for the installation!"
		return 1
	fi
}

check_target_disk_configuration() {
	local rv=1
	check_target_disk_set
	rv=$?
	if [ $rv -ne 0 ]; then
		return $rv
	fi
	check_target_part_sizes_set
	rv=$?
	if [ $rv -ne 0 ]; then
		return $rv
	fi
}

check_configurations() {
	local rv=1
	check_target_disk_set
	rv=$?
	if [ $rv -ne 0 ]; then
		return $rv
	fi
	check_target_part_set
	rv=$?
	if [ $rv -ne 0 ]; then
		return $rv
	fi
	check_target_part_sizes_set
	rv=$?
	if [ $rv -ne 0 ]; then
		return $rv
	fi
}

check_part_type() {
	local part_line=""
	local part_type=""

	case $1 in
	EFI)
		PART_TYPE=${PART_TYPE_EFI}
		;;
	Linux)
		PART_TYPE=${PART_TYPE_LINUX}
		;;
	*)
		return 1
		;;
	esac
	case $2 in
	boot)
		PART_NAME="${TARGET_DISK_SET}1"
		;;
	log)
		PART_NAME="${TARGET_DISK_SET}2"
		;;
	rootA)
		PART_NAME="${TARGET_DISK_SET}3"
		;;
	rootB)
		PART_NAME="${TARGET_DISK_SET}4"
		;;
	*)
		return 1
		;;
	esac
	part_line="$(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${PART_NAME}")"
	if [ -z "$part_line" ]; then
		return 1
	fi
	part_type="$(echo "${part_line[@]}" | sed 's/.*type=//' | sed 's/,.*//')"
	if [ -z "$part_type" ]; then
		return 1
	fi
	if [ "$part_type" != "$PART_TYPE" ]; then
		return 1
	fi
	return 0
}

check_part_size() {
	local part_line=""
	local part_size=""
	local sectors_in_kib=0
	(( sectors_in_kib=1024/$(cat /sys/block/${TARGET_DISK_SET}/queue/hw_sector_size) ))

	if [ $sectors_in_kib -le 0 ]; then
		retrn 1
	fi
	case $1 in
	boot)
		PART_NAME="${TARGET_DISK_SET}1"
		PART_SIZE="${TARGET_BOOT_PARTSZ_SET}"
		;;
	log)
		PART_NAME="${TARGET_DISK_SET}2"
		PART_SIZE="${TARGET_LOG_PARTSZ_SET}"
		;;
	rootA)
		PART_NAME="${TARGET_DISK_SET}3"
		PART_SIZE="${TARGET_ROOTA_PARTSZ_SET}"
		;;
	rootB)
		PART_NAME="${TARGET_DISK_SET}4"
		PART_SIZE="${TARGET_ROOTB_PARTSZ_SET}"
		;;
	*)
		return 1
		;;
	esac
	part_line="$(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${PART_NAME}")"
	if [ -z "$part_line" ]; then
		return 1
	fi
	# num 512 B sectors:
	part_size="$(echo "${part_line[@]}" | sed 's/.*size= *//' | sed 's/,.*//')"
	# num KiB:
	((part_size/=2))
	# num MiB:
	((part_size/=1024))
	# num GiB:
	((part_size/=1024))
	if [ -z "$part_size" ]; then
		return 1
	fi
	if [ "$part_size" != "$PART_SIZE" ]; then
		return 1
	fi
	return 0
}

check_current_target_disk_setup() {
	local action_name="${1}"
	local root_part_label=""
	local msg_warn=""
	local msg_fdisk="$(fdisk -l /dev/${TARGET_DISK_SET})\n"
	local msg_size=17
	local disk_change_needed=0
	local first_sector=0
	local sectors_in_kib=0
	(( sectors_in_kib=1024/$(cat /sys/block/${TARGET_DISK_SET}/queue/hw_sector_size) ))

	if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
		source $U2UP_TARGET_DISK_CONF_FILE
	else
		TARGET_BOOT_PARTSZ_SET=""
	fi
	if [ -n "${TARGET_PART_SET}" ]; then
		if [ "${TARGET_PART_SET}" = "${TARGET_DISK_SET}3" ]; then
			root_part_label="rootA"
		elif [ "${TARGET_PART_SET}" = "${TARGET_DISK_SET}4" ]; then
			root_part_label="rootB"
		fi
	fi
	if \
		[ -n "$TARGET_BOOT_PARTSZ_SET" ] && \
		[ -n "$TARGET_ROOTA_PARTSZ_SET" ] && \
		[ -n "$TARGET_ROOTB_PARTSZ_SET" ] && \
		[ -n "$TARGET_LOG_PARTSZ_SET" ]; \
	then
		# Dump current target disk setup:
		sfdisk -d /dev/${TARGET_DISK_SET} > $U2UP_TARGET_DISK_SFDISK_DUMP
		rm -f $U2UP_TARGET_DISK_SFDISK_BASH

		# Warn, if partition table NOT GPT: 
		if [ $(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "label:" | grep "gpt" | wc -l) -eq 0 ]; then
			msg_warn="${msg_warn}\n! Partition table - wrong type\n"
			msg_warn="${msg_warn}\n=> Partition table is going to be recreated as GPT!\n"
			((msg_size+=4))
			((disk_change_needed+=1))
			cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
echo 'label: gpt' | sfdisk /dev/${TARGET_DISK_SET}
EOF
		fi
		cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
sfdisk -d /dev/${TARGET_DISK_SET} | grep -vE "^\/dev\/${TARGET_DISK_SET}" > $U2UP_TARGET_DISK_SFDISK_DUMP
EOF

########
# BOOT
########
		first_sector="$(sfdisk -d /dev/${TARGET_DISK_SET} | grep "first-lba" | sed 's/^.*: //')"
		(( part_sectors=${TARGET_BOOT_PARTSZ_SET}*${sectors_in_kib}*1024*1024 ))
		# Warn, if BOOT partition MISSING: 
		if [ $(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${TARGET_DISK_SET}1" | wc -l) -eq 0 ]; then
			msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}1) boot partition - Missing\n"
			((msg_size+=2))
			((disk_change_needed+=1))
		else
		# Warn, if BOOT partition NOT EFI: 
			check_part_type "EFI" "boot"
			if [ $? -ne 0 ]; then
				msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}1) boot partition - Not EFI type\n"
				((msg_size+=2))
				((disk_change_needed+=1))
			else
		# Warn, if BOOT partition NOT SIZED: 
				check_part_size "boot"
				if [ $? -ne 0 ]; then
					msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}1) Boot partition - Resized\n"
					((msg_size+=2))
					((disk_change_needed+=1))
				fi
			fi
		fi
		cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
echo "/dev/${TARGET_DISK_SET}1 : size= ${part_sectors}, type=${PART_TYPE_EFI}" >> $U2UP_TARGET_DISK_SFDISK_DUMP
EOF

#######
# LOG
#######
		(( first_sector+=part_sectors ))
		(( part_sectors=${TARGET_LOG_PARTSZ_SET}*${sectors_in_kib}*1024*1024 ))
		# Warn, if LOG partition MISSING: 
		if [ $(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${TARGET_DISK_SET}2" | wc -l) -eq 0 ]; then
			msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}2) log partition - Missing\n"
			((msg_size+=2))
			((disk_change_needed+=1))
		else
		# Warn, if LOG partition NOT LINUX: 
			check_part_type "Linux" "log"
			if [ $? -ne 0 ]; then
				msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}2) log partition - Not Linux type\n"
				((msg_size+=2))
				((disk_change_needed+=1))
			else
		# Warn, if LOG partition NOT SIZED: 
				check_part_size "log"
				if [ $? -ne 0 ]; then
					msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}2) log partition - Resized\n"
					((msg_size+=2))
					((disk_change_needed+=1))
				fi
			fi
		fi
		cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
echo "/dev/${TARGET_DISK_SET}2 : size= ${part_sectors}, type=${PART_TYPE_LINUX}" >> $U2UP_TARGET_DISK_SFDISK_DUMP
EOF

#########
# ROOTA
#########
		(( first_sector+=part_sectors ))
		(( part_sectors=${TARGET_ROOTA_PARTSZ_SET}*${sectors_in_kib}*1024*1024 ))
		# Warn, if ROOTA partition MISSING: 
		if [ $(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${TARGET_DISK_SET}3" | wc -l) -eq 0 ]; then
			msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}3) rootA partition - Missing\n"
			((msg_size+=2))
			((disk_change_needed+=1))
		else
		# Warn, if ROOTA partition NOT LINUX: 
			check_part_type "Linux" "rootA"
			if [ $? -ne 0 ]; then
				msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}3) rootA partition - Not Linux type\n"
				((msg_size+=2))
				((disk_change_needed+=1))
			else
		# Warn, if ROOTA partition NOT SIZED: 
				check_part_size "rootA"
				if [ $? -ne 0 ]; then
					msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}3) rootA partition - Resized\n"
					((msg_size+=2))
					((disk_change_needed+=1))
				fi
			fi
		fi
		cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
echo "/dev/${TARGET_DISK_SET}3 : size= ${part_sectors}, type=${PART_TYPE_LINUX}" >> $U2UP_TARGET_DISK_SFDISK_DUMP
EOF

#########
# ROOTB
#########
		(( first_sector+=part_sectors ))
		(( part_sectors=${TARGET_ROOTB_PARTSZ_SET}*${sectors_in_kib}*1024*1024 ))
		# Warn, if ROOTB partition MISSING: 
		if [ $(cat $U2UP_TARGET_DISK_SFDISK_DUMP | grep "/dev/${TARGET_DISK_SET}4" | wc -l) -eq 0 ]; then
			msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}4) rootB partition - Missing\n"
			((msg_size+=2))
			((disk_change_needed+=1))
		else
		# Warn, if ROOTB partition NOT LINUX: 
			check_part_type "Linux" "rootB"
			if [ $? -ne 0 ]; then
				msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}4) rootB partition - Not Linux type\n"
				((msg_size+=2))
				((disk_change_needed+=1))
			else
		# Warn, if ROOTB partition NOT SIZED: 
				check_part_size "rootB"
				if [ $? -ne 0 ]; then
					msg_warn="${msg_warn}\n! (${TARGET_DISK_SET}4) rootB partition - Resized\n"
					((msg_size+=2))
					((disk_change_needed+=1))
				fi
			fi
		fi
		cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
echo "/dev/${TARGET_DISK_SET}4 : size= ${part_sectors}, type=${PART_TYPE_LINUX}" >> $U2UP_TARGET_DISK_SFDISK_DUMP
EOF

		if [ $disk_change_needed -ne 0 ]; then
			msg_fdisk="${msg_fdisk}\n-----------------------------------"
			msg_warn="${msg_warn}-----------------------------------\n"
			msg_warn="${msg_warn}\n=> Partition table is going to be changed and ALL TARGET DATA LOST!\n"
			((msg_size+=5))
			cat >> $U2UP_TARGET_DISK_SFDISK_BASH << EOF
sfdisk /dev/${TARGET_DISK_SET} < $U2UP_TARGET_DISK_SFDISK_DUMP
EOF
		else
			rm -f ${U2UP_TARGET_DISK_SFDISK_BASH}
			msg_warn="${msg_warn}\n-----------------------------------\n"
			msg_warn="${msg_warn}\n=> Partition table is NOT going to be changed!\n"
			((msg_size+=5))
		fi
		if [ $disk_change_needed -ne 0 ]; then
			if [ "x${action_name}" != "xInstallation" ]; then
				msg_warn="${msg_warn}\nDo you really want to continue?"
				((msg_size+=3))
				display_yesno "${action_name} warning" "${msg_fdisk}${msg_warn}" $msg_size
				if [ $? -eq 0 ]; then
					#Yes
					return 0
				else
					#No
					display_result "${action_name}" "${action_name} interrupted!"
					return 1	
				fi
			else
				msg_warn="${msg_warn}\n${action_name} interrupted?"
				((msg_size+=3))
				display_msg "${action_name} warning" "${msg_fdisk}${msg_warn}" $msg_size
				return 1 # To skip additional "success" message!
			fi
		else
			if [ "x${action_name}" != "xInstallation" ]; then
				display_msg "${action_name} notice" "${msg_fdisk}${msg_warn}" $msg_size
				return 1 # To skip additional "success" message!
			else
				msg_warn="${msg_warn}\n=> You are about to install new system on disk partition:"
				msg_warn="${msg_warn}\n=> [${TARGET_PART_SET} - ${root_part_label}]\n"
				msg_warn="${msg_warn}\nDo you really want to continue?"
				((msg_size+=5))
				display_yesno "${action_name} warning" "${msg_fdisk}${msg_warn}" $msg_size
				if [ $? -eq 0 ]; then
					#Yes
					return 0
				else
					#No
					display_result "${action_name}" "${action_name} interrupted!"
					return 1	
				fi
			fi
		fi
	else
		check_target_disk_configuration
	fi
}

proceed_target_repartition() {
	loacal rv=1
	if [ -f "${U2UP_TARGET_DISK_SFDISK_BASH}" ]; then
		echo "Re-partitioning disk:"
		bash ${U2UP_TARGET_DISK_SFDISK_BASH}
		if [ $? -ne 0 ]; then
			echo "press any key to continue..."
			read
			display_result "Re-partition" "Failed to re-partition disk!"
			return 1
		fi
		sfdisk -V /dev/${TARGET_DISK_SET}
		if [ $? -ne 0 ]; then
			echo "press any key to continue..."
			read
			display_result "Re-partition" "Failed to re-partition disk!"
			return 1
		fi
	fi
	echo "press any key to continue..."
	read
	display_result "Re-partition" "Re-partition successfully finished!"
}

execute_target_repartition() {
	local rv=0
	check_target_disk_configuration
	rv=$?
	if [ $rv -eq 0 ]; then
		check_current_target_disk_setup "Re-partition"
		rv=$?
		if [ $rv -eq 0 ]; then
			proceed_target_repartition
			rv=$?
		fi
	fi
	return $rv
}

display_target_partsizes_submenu() {
	local current_set=""
	local target_disk_current=$1
	local target_boot_partsz_current=${2:-2}
	local target_log_partsz_current=${3:-5}
	local target_rootA_partsz_current=${4:-20}
	local target_rootB_partsz_current=${5:-20}

	while true; do
		exec 3>&1
		selection=$(IFS='|'; \
		dialog \
			--backtitle "${U2UP_BACKTITLE}" \
			--title "Target partitions" \
			--clear \
			--cancel-label "Cancel" \
			--extra-label "Resize" \
			--cr-wrap \
			--inputmenu $(fdisk -l /dev/${target_disk_current})"\n\nPlease select:" $HEIGHT 0 15 \
			"boot  [/dev/${target_disk_current}1] (GiB):" ${target_boot_partsz_current} \
			"log   [/dev/${target_disk_current}2] (GiB):" ${target_log_partsz_current} \
			"rootA [/dev/${target_disk_current}3] (GiB):" ${target_rootA_partsz_current} \
			"rootB [/dev/${target_disk_current}4] (GiB):" ${target_rootB_partsz_current} \
		2>&1 1>&3)
		exit_status=$?
		exec 3>&-

		case $exit_status in
		$DIALOG_CANCEL|$DIALOG_ESC)
			clear
			echo "Return from submenu."
			return 1
			;;
		esac

		current_set="$(store_target_partsize_selection $selection)"
		if [ -n "$current_set" ]; then
			#Resize pressed: set new dialog values
			eval $current_set
		else
			#Ok
			store_target_partsize_selection "boot :${target_boot_partsz_current}"
			store_target_partsize_selection "log :${target_log_partsz_current}"
			store_target_partsize_selection "rootA :${target_rootA_partsz_current}"
			store_target_partsize_selection "rootB :${target_rootB_partsz_current}"
			execute_target_repartition
			return $?
		fi
	done
}

proceed_target_install() {
	echo DONE!
	exit	
}

execute_target_install() {
	check_configurations
	if [ $? -eq 0 ]; then
		check_current_target_disk_setup "Installation"
		if [ $? -eq 0 ]; then
			proceed_target_install
		fi
	fi
}

display_execute_target_install() {
	mkdir -p u2up-images/log
	touch u2up-images/log/install-log
	dialog \
		--backtitle "${U2UP_BACKTITLE}" \
		--title "Install" \
		--begin 10 10 \
		--tailboxbg u2up-images/log/install-log 5 100 \
		--and-widget \
		--begin 3 10 --msgbox "Press OK" 5 30
	execute_target_install
}

main_loop () {
	local current_tag='1'
	local root_part_label
	local KEYMAP_SET=""
	local TARGET_DISK_SET=""
	local TARGET_PART_SET=""
	local TARGET_BOOT_PARTSZ_SET=""
	local TARGET_LOG_PARTSZ_SET=""
	local TARGET_ROOTA_PARTSZ_SET=""
	local TARGET_ROOTB_PARTSZ_SET=""

	while true; do
		if [ -f "${U2UP_KEYMAP_CONF_FILE}" ]; then
			source $U2UP_KEYMAP_CONF_FILE
		fi
		if [ -f "${U2UP_TARGET_DISK_CONF_FILE}" ]; then
			source $U2UP_TARGET_DISK_CONF_FILE
		fi
		root_part_label=""
		if [ -n "${TARGET_PART_SET}" ]; then
			if [ "${TARGET_PART_SET}" = "${TARGET_DISK_SET}3" ]; then
				root_part_label="rootA"
			elif [ "${TARGET_PART_SET}" = "${TARGET_DISK_SET}4" ]; then
				root_part_label="rootB"
			fi
		fi

		exec 3>&1
		selection=$(dialog \
			--backtitle "${U2UP_BACKTITLE}" \
			--title "Menu" \
			--clear \
			--cancel-label "Exit" \
			--default-item $current_tag \
			--menu "Please select:" $HEIGHT $WIDTH 5 \
			"1" "Keyboard mapping [${KEYMAP_SET}]" \
			"2" "Target disk [${TARGET_DISK_SET}]" \
			"3" "Disk partitions \
[boot:${TARGET_BOOT_PARTSZ_SET}G] \
[log:${TARGET_LOG_PARTSZ_SET}G] \
[rootA:${TARGET_ROOTA_PARTSZ_SET}G] \
[rootB:${TARGET_ROOTB_PARTSZ_SET}G]" \
			"4" "Installation partition [${TARGET_PART_SET} - ${root_part_label}]" \
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
			local target_boot_partsz_old=$TARGET_BOOT_PARTSZ_SET
			local target_log_partsz_old=$TARGET_LOG_PARTSZ_SET
			local target_rootA_partsz_old=$TARGET_ROOTA_PARTSZ_SET
			local target_rootB_partsz_old=$TARGET_ROOTB_PARTSZ_SET
			display_target_partsizes_submenu \
				$TARGET_DISK_SET \
				$TARGET_BOOT_PARTSZ_SET \
				$TARGET_LOG_PARTSZ_SET \
				$TARGET_ROOTA_PARTSZ_SET \
				$TARGET_ROOTB_PARTSZ_SET
			if [ $? -ne 0 ]; then
				# Restore old partition sizes
				store_target_partsize_selection "boot :${target_boot_partsz_old}"
				store_target_partsize_selection "log :${target_log_partsz_old}"
				store_target_partsize_selection "rootA :${target_rootA_partsz_old}"
				store_target_partsize_selection "rootB :${target_rootB_partsz_old}"
			fi
			;;
		4)
			display_target_part_submenu \
				$TARGET_DISK_SET \
				$TARGET_PART_SET
			;;
		5)
			execute_target_install
			;;
		esac
	done
}

main_loop

