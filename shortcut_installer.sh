#!/bin/bash
# shorcut installer for CCX-BOX_Apps updater for Ubuntu users
# this file is subject to Licence
# Copyright (c) 2024, Acktarius
#
# make sure ./shortcut_installer.sh is an executable file
# otherwise, run: sudo chmod 755 shortcut_installer.sh
# run with command: sudo ./shortcut_installer.sh
#
#
#variables
# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    zenity --error \
        --title="Root Privileges Required" \
        --text="This script needs to be run as root.\n\nPlease run:\nsudo $0"
    exit 1
fi

# Get the actual user who ran the script with sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create user applications directory if it doesn't exist
mkdir -p "${REAL_HOME}/.local/share/applications"
#Functions
shortcutCreator() {
cat << EOF > ${REAL_HOME}/.local/share/applications/CCX-BOX_Apps_updater.desktop
[Desktop Entry]
Encoding=UTF-8
Name=CCX-BOX App updater
Path=${SCRIPT_DIR}
Exec=gnome-terminal --title=CCX-BOX_Apps_updater --active --geometry=80x45 -- bash -c 'sudo ${SCRIPT_DIR}/updater.sh ; exit'
Terminal=false
Type=Application
Icon=${SCRIPT_DIR}/icon/update_box.png
Hidden=false
NoDisplay=false
Terminal=false
Categories=Office
X-GNOME-Autostart-enabled=true
Comment=Update your CCX BOX
EOF
# Update desktop database
update-desktop-database "${REAL_HOME}/.local/share/applications"
}
already() {
read -p  "shortcut already in place, do you want to replace it (y/N)" ans
	case $ans in
		y | Y | yes)
		rm -f ${REAL_HOME}/.local/share/applications/CCX-BOX_Apps_updater.desktop
		shortcutCreator
		;;
		*)
		echo "nothing done"
		;;
	esac
}
#check and install
##not already install
if [[ ! -f ${REAL_HOME}/.local/share/applications/CCX-BOX_Apps_updater.desktop ]]; then 
shortcutCreator
else
already
fi
