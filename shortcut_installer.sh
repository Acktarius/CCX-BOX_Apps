#!/bin/bash
# shorcut installer for CCX-BOX_Apps updater for Ubuntu users
# this file is subject to Licence
# Copyright (c) 2024, Acktarius
#
# make sure ./shortcut_installer.sh is an executable file
# otherwise, run: sudo chmod 755 shortcut_installer.sh
# run with command: ./shortcut_installer.sh
#
#
#variables
user=$(id -nu 1000)
path=$(pwd)
#Functions
shortcutCreator() {
cat << EOF > /home/${user}/.local/share/applications/CCX-BOX_Apps_updater.desktop
[Desktop Entry]
Encoding=UTF-8
Name=CCX-BOX App updater
Path=${path}
Exec=gnome-terminal --title=CCX-BOX_Apps_updater --active --geometry=80x45 -- bash -c 'sudo ${path}/updater.sh ; exit'
Terminal=false
Type=Application
Icon=${path}/icon/update_box.png
Hidden=false
NoDisplay=false
Terminal=false
Categories=Office
X-GNOME-Autostart-enabled=true
Comment=Update your CCX BOX
EOF
echo "shortcut created, you may have to log out and log back in"
}
already() {
read -p  "shortcut already in place, do you want to replace it (y/N)" ans
	case $ans in
		y | Y | yes)
		rm -f /home/${user}/.local/share/applications/CCX-BOX_Apps_updater.desktop
		shortcutCreator
		;;
		*)
		echo "nothing done"
		;;
	esac
}
#check and install
##not already install
if [[ ! -f /home/${user}/.local/share/applications/CCX-BOX_Apps_updater.desktop ]]; then 
shortcutCreator
else
already
fi
