#!/bin/bash
################################################################################
# this file is subject to Licence
#Copyright (c) 2024, Acktarius
################################################################################

#base functions
#trip
trip() {
kill -INT $$
}

#present Directory
presentDir=$(pwd)

#version
version() {
echo "$(jq .version ${1}/${2} | xargs)"
}

#continu
continu(){
echo -e "\n"
read -n 1 -p "Press any key to Continue or Quit (anykey|Q)" answer
case $answer in
	Q|q)
	trip
	;;
	*) 
	echo -e "\n"
	sleep 1
	;;
esac	
}

#general Check
#Check Zenity
if ! command -v zenity &> /dev/null; then
echo "zenity not install"
sleep 1
trip
fi

#check jq installed
if ! command -v jq &> /dev/null; then
echo -e "jq not install\nrun following command to install it\nsudo apt-get install jq"
sleep 1
trip
fi

#Couleurs
case "$TERM" in
        xterm-256color)
        WHITE=$(tput setaf 7 bold)
        ORANGE=$(tput setaf 202)
        GRIS=$(tput setaf 245)
	LINK=$(tput setaf 4 smul)
        TURNOFF=$(tput sgr0)
        ;;
        *)
        WHITE=''
	ORANGE=''
        GRIS=''
	LINK=''
        TURNOFF=''
        ;;
esac
#Presentation
presentation (){
clear
echo -e "${GRIS}####################################################################"
echo -e "#                                                                  #"
echo -e "#-->   ${WHITE}               UPDATE YOUR CCX-BOX            ${TURNOFF}${GRIS}           <--#"
echo -e "#                                                                  #"
echo -e "#                                                                  #"
echo -e "####################################################    ${WHITE}.::::."
echo -e "${GRIS}#                                                   ${WHITE}.:---=--=--::."
echo -e "${GRIS}#${WHITE}  Script will check repository to update:\t    -=:+-.  .-=:=:"
echo -e "${GRIS}#                                                   ${WHITE}-=:+."
echo -e "${GRIS}#                                                   ${WHITE}-=:+."
echo -e "${GRIS}#                                                   ${WHITE}-=:+."
echo -e "${GRIS}#						    ${WHITE}-=:=."
echo -e "${GRIS}#                                                   ${WHITE}-+:-:    .::."
echo -e "${GRIS}#						    ${WHITE}-+==------===-"
echo -e "${GRIS}########                                               ${WHITE}:-=-==-:${TURNOFF}"
echo -e "${GRIS}# \t\t${1}/${ORANGE}${2} ${TURNOFF}\n"
}

#update functions
proceed() {
read -p "Do you wish to proceed? (Yes|No)" ans
case $ans in
	Y|y|yes|YES|Yes)
	echo "Starting update..."
	update $1 $2
	;;
	N|n|no|NO|No)
	echo "nothing will be done"
	;;
	*)
	echo "unexpected answer"
	;;
esac	
}


update() {
read -p "Do you want to Merge(save modification) or Clean install(local tracked file will be lost) (Merge|Clean)?" choix
case $choix in
	M|m|Merge)
	merge $1 $2
	;;
	C|c|Clean|clean)
	clean $1 $2
	;;
	*)
	trip
	;;
esac
}

merge(){
cd $1
set -e
#check if local branch, if not, will create it
if [[ $(git branch --list | grep -c "local") -eq 0 ]]; then
git checkout -b local
else
git checkout local
fi
git add .
git commit -m "mylocal"
git checkout $(git remote show origin | grep "HEAD branch" |  xargs | cut -d " " -f 3)
git merge local
	if [[ $2 == "npm" ]]; then npm install; fi
cd $presentDir
}

clean(){
cd $1
set -e
git fetch
git reset --hard origin/$(git remote show origin | grep "HEAD branch" |  xargs | cut -d " " -f 3)
	if [[ $2 == "npm" ]]; then npm install; fi
cd $presentDir
}

gitInstall(){
cd $1
	case $2 in
		"conceal-assistant")
		if [[ -f ./${2}/data/miners.json ]]; then
		cp ./${2}/data/miners.json miners_tmp.json
		fi
		if [[ -f ./${2}/data/users.json ]]; then
		cp ./${2}/data/users.json users_tmp.json
		fi
		if [[ -f ./${2}/.env ]]; then
		cp ./${2}/.env .env_tmp 
		fi
		;;
		"conceal-guardian")
		if [[ -f ./${2}/config.json ]]; then
		cp ./${2}/config.json config_tmp.json
		fi
		;;
		*)
		;;
	esac
rm -rf $2
	case $2 in
		"conceal-assistant")
		git clone https://github.com/Acktarius/${2}.git
		cd $2
		npm install && cd ..
		;;
		"conceal-guardian")
		git clone https://github.com/ConcealNetwork/conceal-guardian.git
		cd $2
		npm install && cd ..
		;;
		*)
		git clone https://github.com/Acktarius/${2}.git
		chmod +x ./$2/*.sh
		;;
	esac
	case $2 in
		"conceal-assistant")
		if [[ -f miners_tmp.json ]]; then
		mv miners_tmp.json ./${2}/data/miners.json
		fi
		if [[ -f users_tmp.json ]]; then
		mv users_tmp.json ./${2}/data/users.json
		fi
		if [[ -f .env_tmp ]]; then
		mv .env_tmp ./${2}/.env 
		fi
		;;
		"conceal-guardian")
		if [[ -f config_tmp.json ]]; then
		mv config_tmp.json ./${2}/config.json 
		fi
		;;
		*)
		;;
	esac
cd $presentDir
}

#for Anyfolder
#check directory
checkRepo() {
clear 
presentation ${1} ${2}
anyDir="${1}/${2}"
#echo -e "$anyDir\n"
#folder check
if [[ -d $anyDir ]]; then
echo "${2} folder detected "
else
anyDir=$(zenity --file-selection --directory --title="Select your ${2} directory")
case $? in
         0)
                echo "\"$anyDir\" selected.";;
         1)
                echo "No Directory selected."
                trip
                ;;
        -1)
                echo "An unexpected error has occurred.";;
esac
fi
#check .git folder 		--------------------------------------------------------------- <<<<< No .Git
if [[ ! -d $anyDir/.git ]]; then
echo ".git folder not found, you should consider updating using deb release file"
sleep 1
read -p "or do you wish to re-install from git repository (Y|N)" select
	case $select in
		Y|y|Yes|YES)
		gitInstall $1 $2
		;;
		*)
		;;
	esac
else 					#--------------------------------------------------------------- <<<<< .Git
echo -e "and there is a .git folder"
#check version with package.json ------------------------------------------------------- <<<<<< package.json
	if [[ -f $anyDir/package.json ]]; then
	anyVinst=$(version $anyDir "package.json")
	anyVgit=$(curl -s ${3} | jq .version | xargs)
	#anyVgit="1.5.0"
	compAnyV=$(echo -e "$anyVinst\n$anyVgit" | sort -V | head -n1)

		if [[ $compAnyV != $anyVinst ]]; then
		echo "you have version $anyVinst installed, github version is $anyVgit, nothing will be done"
		else
			if [[ $anyVinst == $anyVgit ]]; then
			echo -e "\n${ORANGE}${2} ${GRIS}is up to date at version ${ORANGE}$anyVinst${GRIS} , nothing will be done"
			else
			echo -e "you have version $anyVinst installed, github version is $anyVgit\nlooks like you're due for an update !"
			proceed $anyDir "npm"
			fi
		fi
	#check version with git diff -------------------------------------------------------- <<<<<<<< ! package.json
	else
	cd $anyDir
	git diff HEAD^ HEAD --compact-summary
	cd $presentDir
	proceed $anyDir "no"
	fi
fi
continu
}

checkRepo "/opt" "conceal-assistant" "https://raw.githubusercontent.com/Acktarius/conceal-assistant/main/package.json"
checkRepo "/opt" "EZ_Privacy" "https://raw.githubusercontent.com/Acktarius/EZ_Privacy/main/package.json"
checkRepo "/opt" "conceal-guardian" "https://raw.githubusercontent.com/ConcealNetwork/conceal-guardian/master/package.json"
checkRepo "/opt/conceal-toolbox" "ping_ccx_pool"
checkRepo "/opt/conceal-toolbox" "mem-alloc-fail_solver"

#git diff HEAD^ HEAD --compact-summary