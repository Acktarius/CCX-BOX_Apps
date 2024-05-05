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
echo -e "${GRIS}###   ${WHITE}               UPDATE YOUR CCX-BOX            ${TURNOFF}${GRIS}               #"
echo -e "#                                                                  #"
echo -e "#                                                                  #"
echo -e "####################################################    ${WHITE}.::::."
echo -e "${GRIS}#                                                   ${WHITE}.:---=--=--::."
echo -e "#${WHITE} Script will check repository to update:\t    -=:+-.  .-=:=:"
echo -e "${GRIS}#					\t    ${WHITE}-=:+."
echo -e "${WHITE}# "${1}/${2}"\t\t\t\t    -=:+."
echo -e "${GRIS}#                                                   ${WHITE}-=:+."
echo -e "${GRIS}#						    ${WHITE}-=:=."
echo -e "${GRIS}#                                                   ${WHITE}-+:-:    .::."
echo -e "${GRIS}#						    ${WHITE}-+==------===-"
echo -e "${GRIS}####################################################   ${WHITE}:-=-==-:${TURNOFF}\n"
}

#update functions
proceed() {
read -p "Do you wish to proceed? (Yes|No)" ans
case $ans in
	Y|y|yes|YES|Yes)
	echo "Starting update..."
	update $1
	;;
	N|n|no|NO|No)
	echo "nothing will be done"
	;;
	*)
	echo "unexpected answer"
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
git checkout $(git rev-parse --abbrev-ref HEAD)
git merge local
npm install
cd $presentDir
}

clean(){
cd $1
set -e
git fetch
git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
npm install
cd $presentDir
}

update() {
read -p "Do you want to Merge(save modification) or Clean install(local tracked file will be lost) (Merge|Clean)?" choix
case $choix in
	M|m|Merge)
	merge $1
	;;
	C|c|Clean|clean)
	clean $1
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
                echo "No Directory selected."
                trip
                ;;
        -1)
                echo "An unexpected error has occurred.";;
esac
fi
#check .git folder 
if [[ ! -d $anyDir/.git ]]; then
echo ".git folder not found, you should consider updating using deb release file"
else
echo -e "and there is a .git folder"
#check version with package.json
if [[ -f $anyDir/package.json ]]; then
anyVinst=$(version $anyDir "package.json")
anyVgit=$(curl -s ${3} | jq .version | xargs)
#anyVgit="1.5.0"
compAnyV=$(echo -e "$anyVinst\n$anyVgit" | sort -V | head -n1)

if [[ $compAnyV != $anyVinst ]]; then
echo "you have version $anyVinst installed, github version is $anyVgit, nothing will be done"
else
if [[ $anyVinst == $anyVgit ]]; then
echo "you 're up to date, nothing will be done"
else
echo -e "you have version $anyVinst installed, github version is $anyVgit\nlooks like you're due for an update !"
proceed $anyDir
fi
fi
#check version with git diff
else
cd $anyDir
git diff HEAD^ HEAD --compact-summary

fi
fi
continu
}

checkRepo "/opt" "conceal-assistant" "https://raw.githubusercontent.com/Acktarius/conceal-assistant/main/package.json"
checkRepo "/opt" "EZ_Privacy" "https://raw.githubusercontent.com/Acktarius/EZ_Privacy/main/package.json"
checkRepo "/opt" "conceal-guardian" "https://raw.githubusercontent.com/ConcealNetwork/conceal-guardian/master/package.json"
#checkRepo "/opt/conceal-toolbox" "ping_ccx_pool"


#git diff HEAD^ HEAD --compact-summary
