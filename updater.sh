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
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#version
version() {
echo "$(jq .version ${1}/${2} | xargs)"
}

#continu
continu(){
echo -e "\n${GRIS}Press any key to Continue or Quit (anykey|Q)${TURNOFF}"
read -n 1 answer
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
echo "zenity not install\nrun following command to install it\nsudo apt-get install zenity"
sleep 3
trip
fi

#check jq installed
if ! command -v jq &> /dev/null; then
echo -e "jq not install\nrun following command to install it\nsudo apt-get install jq"
sleep 4
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

readonly REPOS_CONFIG="${SCRIPT_DIR}/repos.json"

validate_config() {
    if [[ ! -f "${REPOS_CONFIG}" ]]; then
        echo "Error: Configuration file ${REPOS_CONFIG} not found"
        trip
    fi
}

#Presentation
presentation (){
clear
echo -e "${GRIS}####################################################################"
echo -e "#                                                                  #"
echo -e "#-->   ${WHITE}               UPDATE YOUR CCX-BOX            ${TURNOFF}${GRIS}           <--#"
echo -e "#                                                                  #"
echo -e "#                                                           ${WHITE}v$(cat package.json | jq .version | xargs)${GRIS} #"
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
echo -e "${GRIS}# \t${1}/${ORANGE}${2} ${TURNOFF}\n"
}

#update functions
proceed() {
echo -e "${WHITE}Do you wish to proceed? (Yes|No)${TURNOFF}"	
read ans
case $ans in
	Y|y|yes|YES|Yes)
	echo "Starting update..."
	update $1 $2 $3 $4
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
read -p "Do you want to Merge(save modification) or Clean install(you'll lose your config) (Merge|Clean)?" choix
case $choix in
	M|m|Merge)
	gitInstall $1 $2 $3 $4 "m"
	;;
	C|c|Clean|clean)
	gitInstall $1 $2 $3 $4 "c"
	;;
	*)
	trip
	;;
esac
}

gitInstall(){
cd $1
	case $5 in
		"m")
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
			if [[ -f ./${2}/data/log.txt ]]; then
			echo -e "$(date +'%Y%m%d')\t$(date +'%T')\tupdate conceal assistant"  >> /${2}/data/log.txt
			cp ./${2}/data/log.txt log_tmp.txt 
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
		git clone $4
		case $3 in
			"npm")
			cd $2
			npm install 
			cd ..
			;;
			"no")
			chmod +x ./$2/*.sh
			;;
			*)
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
			if [[ -f log_tmp.txt ]]; then
			mv log_tmp.txt ./${2}/data/log.txt 
			fi
			cp ./conceal-assistant/launcher/ccx-assistant_firefox.sh /opt/conceal-toolbox/
			;;
			"conceal-guardian")
			if [[ -f config_tmp.json ]]; then
			mv config_tmp.json ./${2}/config.json 
			fi
			;;
			*)
			;;
		esac
	;;
	"c")
		rm -rf $2
		git clone $4
		if [[ "$3" == "npm" ]]; then 
		cd $2
		npm install
		cd ..
		fi
	;;
	*)
	trip
	;;
	esac

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
                echo "No Directory selected.";;
        *)
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
		proceed $1 $2 $3 $4
		;;
		*)
		;;
	esac
else 					#--------------------------------------------------------------- <<<<< .Git
echo -e "and there is a .git folder"
#check version with package.json ------------------------------------------------------- <<<<<< package.json
	if [[ -f $anyDir/package.json ]]; then
	anyVinst=$(version $anyDir "package.json")
	anyVgit=$(curl -s ${5} | jq .version | xargs)
	#anyVgit="1.5.0" -------------------------------------------------------------------- <<<<<<<<<<<<<< Testing purpose
	compAnyV=$(echo -e "$anyVinst\n$anyVgit" | sort -V | head -n1)

		if [[ $compAnyV != $anyVinst ]]; then
		echo "you have version $anyVinst installed, github version is $anyVgit, nothing will be done"
		else
			if [[ $anyVinst == $anyVgit ]]; then
			echo -e "\n${ORANGE}${2} ${GRIS}is up to date at version ${ORANGE}$anyVinst${GRIS} , nothing will be done"
			else
			echo -e "you have version $anyVinst installed, github version is $anyVgit\nlooks like you're due for an update !"
			proceed $1 $2 $3 $4
			fi
		fi
	#check version with git diff -------------------------------------------------------- <<<<<<<< ! package.json
	else
	cd $anyDir
	git diff HEAD^ HEAD --compact-summary
	proceed $1 $2 $3 $4
	fi
fi
continu
}

#MAIN
validate_config

# Check if repos.json has valid content
if ! jq empty "$REPOS_CONFIG" 2>/dev/null; then
    echo "Error: Invalid JSON in $REPOS_CONFIG"
    trip
fi

# Check if repositories array exists and is not empty
repo_count=$(jq '.repositories | length' "$REPOS_CONFIG")
if [[ $repo_count -eq 0 ]]; then
    echo "Error: No repositories found in $REPOS_CONFIG"
    trip
fi

# Loop through each repository
for ((i=0; i<repo_count; i++)); do
    basePath=$(jq -r ".repositories[$i].basePath" "$REPOS_CONFIG")
    subFolder=$(jq -r ".repositories[$i].subFolder" "$REPOS_CONFIG")
    npmOption=$(jq -r ".repositories[$i].npmOption" "$REPOS_CONFIG")
    gitUrl=$(jq -r ".repositories[$i].gitUrl" "$REPOS_CONFIG")
    packageUrl=$(jq -r ".repositories[$i].packageUrl" "$REPOS_CONFIG")
    
    checkRepo "$basePath" "$subFolder" "$npmOption" "$gitUrl" "$packageUrl"
done