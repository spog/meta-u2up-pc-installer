if [ -f "/var/lib/u2up-images/u2up-pc-installer.tgz" ]; then
	if [ ! -f "/var/lib/u2up-images/u2up-pc-installer_ready" ]; then
		tar xzvf /var/lib/u2up-images/u2up-pc-installer.tgz -C /
		if [ $? -eq 0 ]; then
			touch /var/lib/u2up-images/u2up-pc-installer_ready
		else
			rm -f /var/lib/u2up-images/u2up-pc-installer_ready
		fi
	fi
	if [ -f "/var/lib/u2up-images/u2up-pc-installer_ready" ]; then
		if [ $(basename $(tty)) = "tty1" ]; then
			/usr/bin/u2up-pc-installer.sh
		fi
	fi
fi
