#!/bin/bash

# disable blueman applet since it crashes (BUG, 12.02.2016)
mkdir -p ~linuxadmin/.config/autostart
cp dateien/blueman.desktop /home/linuxadmin/.config/autostart/
chown linuxadmin:linuxadmin /home/linuxadmin/.config/autostart/blueman.desktop
rm /etc/skel/.config/autostart/ubuntu-mate-welcome.desktop
