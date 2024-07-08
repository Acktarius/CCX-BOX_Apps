# CCX-BOX_Apps
Apps updater for CCX-BOX users

once downloaded make sure updater.sh and shortcut_installer are executable
`sudo chmod +x updater.sh shortcut_installer.sh`

## Dependencies
make sure you appropriate version of **nodejs** (version 20 is required for guardian)  
`sudo apt-get update`  
* Zenity, in case you need to to select a different folder
`sudo apt-get install zenity`  
* jq, to get json info
`sudo apt-get install jq`

## Install
in terminal :  

`cd /opt/conceal-toolbox`  
`sudo git clone https://github.com/Acktarius/CCX-BOX_Apps.git`  
`cd CCX-BOX_Apps`  
`./shortcut_installer.sh` 

## APPs managed :
* Conceal Assistant
* Conceal Guardian
* CCX ping pool
* EZ_Privacy
* mem_alloc_fail

## How does is work ?
it uses git command to merge the local repository with the HEAD branch.  
if App folder is found but without a .git, it will offer the option to
reclone the main branch. (Config files will be saved and re-injected).