# CCX-BOX_Apps
Apps updater for CCX-BOX users

once downloaded make sure updater.sh and shortcut_installer are executable
`sudo chmod +x updater.sh shortcut_installer.sh`


## Install
in terminal :  

`cd /opt/conceal-toolbox`  
`sudo git clone https://github.com/Acktarius/CCX-BOX_Apps.git`  
`cd CCX-BOX_Apps`  
`sudo ./shortcut_installer.sh` 

## APPs managed :
* Conceal Assistant (except shortcut)
* Conceal Guardian
* CCX ping pool
* EZ_Privacy
* mem_alloc_fail

## How does is work ?
it uses git command to merge the local repository with the HEAD branch.  
if App folder is found but without a .git, it will offer the option to
reclone the main branch. (Config files will be saved and re-injected).