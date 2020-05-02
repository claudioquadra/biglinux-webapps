#!/bin/bash

#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=biglinux-webapps

if [ "$p_namedesk" = "" -a "$p_urldesk" = "" ]
then

	kdialog --error $"\nNenhum dado inserido... \nPor favor, insira e tente novamente! \n"

	#Redirecionar automaticamente
    echo '<script>window.location.replace("index-install.sh.htm");</script>'
    exit
fi


NAMEDESK=$(echo "$p_namedesk" |\
           sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚüÜçÇ/aAaAaAaAeEeEiIoOoOoOuUuUcC/' |\
           tr '[:upper:]' '[:lower:]' |\
           sed 's|\ |-|g;s|\/|-|g')

if [ "$(echo "$p_urldesk" | egrep "(http|https)://")" != "" ]
then
	CUT_HTTP=$(echo "$p_urldesk" |\
                     sed 's/https:\/\///;s/http:\/\///' |\
                     tr '/' '_' |\
                     sed 's/_/__/1;s/_$//;s/_$//')

elif [ "$p_urldesk" = "" ]
then
	kdialog --error $"Você não inseriu a url! \n Por favor, verifique e tente novamente!"
	echo '<script>window.location.replace("index-install.sh.htm");</script>'
	exit
else
	kdialog --error $"A url inserida é inválida! \n Por favor, verifique sua url e tente novamente!"
	echo '<script>window.location.replace("index-install.sh.htm");</script>'
	exit
fi

ICONFILE=$(echo "$p_icondesk" | awk -F'/' '{print $NF}')
if [ ! -e "$p_icondesk" ]; then
	ICON_FILE="preferences-web-browser-shortcuts"
else
	cp -u "$p_icondesk" "$HOME/.local/share/icons"
	ICON_FILE="$HOME/.local/share/icons/$ICONFILE"
fi

if [ ! -e $HOME/.local/share/desktop-directories/web-apps-custom.directory ]
then

echo "[Desktop Entry]
Type=Directory
Name=Web apps Custom
Icon=preferences-web-browser-shortcuts" > /tmp/web-apps-custom.directory

echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$p_namedesk
Exec=/usr/bin/biglinux-webapp --class=\"$CUT_HTTP,Chromium-browser\" --profile-directory=Default --app=$p_urldesk
Icon=$ICON_FILE
StartupWMClass=$CUT_HTTP" > /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop

install_dir_desk=1

else

echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$p_namedesk
Exec=/usr/bin/biglinux-webapp --class=\"$CUT_HTTP,Chromium-browser\" --profile-directory=Default --app=$p_urldesk
Icon=$ICON_FILE
StartupWMClass=$CUT_HTTP" > /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop

install_desk=1

fi

if [ "$install_dir_desk" = "1" ]
then
    xdg-desktop-menu install --novendor /tmp/web-apps-custom.directory /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop
    rm /tmp/web-apps-custom.directory
    rm /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop

    kdialog --msgbox $"\nO WebApp personalizado foi criado com sucesso! \n"
    kdialog --yesno $"\nVocê deseja criar outro WebApp personalizado? \n"

    if [ "$?" != "0" ]; then
        echo '<script>window.location.replace("index.sh.htm");</script>'
        exit
    else
        echo '<script>window.location.replace("index-install.sh.htm");</script>'
        exit
    fi
elif [ "$install_desk" = "1" ]
then
    xdg-desktop-menu install --novendor $HOME/.local/share/desktop-directories/web-apps-custom.directory \
    /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop
    rm /tmp/"$NAMEDESK"-webapp-biglinux-custom.desktop

    kdialog --msgbox $"\nO WebApp personalizado foi criado com sucesso! \n"
    kdialog --yesno $"\nVocê deseja criar outro WebApp personalizado? \n"

    if [ "$?" != "0" ]; then
        echo '<script>window.location.replace("index.sh.htm");</script>'
        exit
    else
        echo '<script>window.location.replace("index-install.sh.htm");</script>'
        exit
    fi
else
    kdialog --error $"\nAlgo de errado aconteceu... \nPor favor, tente novamente! \n"
    echo '<script>window.location.replace("index-install.sh.htm");</script>'
    exit
fi