#!/bin/bash

# disable blueman applet since it crashes (BUG, 12.02.2016)
cp dateien/blueman.desktop /home/linuxadmin/.config/autostart
chown linuxadmin:linuxadmin /home/linuxadmin/.config/autostart/blueman.desktop
