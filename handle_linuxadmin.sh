#!/bin/bash

# remove unnecessary files
cd /home/linuxadmin/
rm -rf Bilder Dokumente Downloads Musik Öffentlich Vorlagen Videos

su - linuxadmin -c "dbus-launch gsettings set org.mate.screensaver idle-activation-enabled false"
su - linuxadmin -c "dbus-launch gsettings set org.mate.screensaver lock-enabled false"
su - linuxadmin -c "dbus-launch gsettings set org.mate.power-manager button-power nothing"
su - linuxadmin -c "dbus-launch gsettings set org.mate.lockdown disable-user-switching true"
su - linuxadmin -c "dbus-launch gsettings set org.mate.lockdown disable-lock-screen true"

