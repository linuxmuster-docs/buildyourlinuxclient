#!/bin/bash

ADMINUSER=linuxadmin

# remove unnecessary files
cd ~${ADMINUSER}/
rm -rf Bilder Dokumente Downloads Musik Öffentlich Vorlagen Videos
# replace default-dirs
mkdir -p ~${ADMINUSER}/.config
mv Schreibtisch Desktop
# all by $HOME, except DESKTOP
cat <<EOF > ~${ADMINUSER}/.config/user-dirs.dirs
# This file is written by xdg-user-dirs-update
# If you want to change or add directories, just edit the line you're
# interested in. All local changes will be retained on the next run
# Format is XDG_xxx_DIR="$HOME/yyy", where yyy is a shell-escaped
# homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
# absolute path. No other format is supported.
# 
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/"
XDG_TEMPLATES_DIR="$HOME/"
XDG_PUBLICSHARE_DIR="$HOME/"
XDG_DOCUMENTS_DIR="$HOME/"
XDG_MUSIC_DIR="$HOME/"
XDG_PICTURES_DIR="$HOME/"
XDG_VIDEOS_DIR="$HOME/"
EOF

su - ${ADMINUSER} -c "dbus-launch gsettings set org.mate.screensaver idle-activation-enabled false"
su - ${ADMINUSER} -c "dbus-launch gsettings set org.mate.screensaver lock-enabled false"
su - ${ADMINUSER} -c "dbus-launch gsettings set org.mate.power-manager button-power nothing"
su - ${ADMINUSER} -c "dbus-launch gsettings set org.mate.lockdown disable-user-switching true"
su - ${ADMINUSER} -c "dbus-launch gsettings set org.mate.lockdown disable-lock-screen true"


### Profil für mozilla firefox:
### -> keine kommandozeilen anpassungen bekannt -> alles von hand machen:
### xhost +
### su - linuxadmin -c "firefox"
### zufälliger Verzeichnisnamen umbennenen in
### .mozilla/firefox/vorlage.default + in
### .mozilla/firefox/profiles.ini umbenennen
