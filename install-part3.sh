#!/bin/bash
# Installationsskript Teil 3
#
# linuxmuster@gymneureut.de
# 2.02.2016
# GPL v3
#

. ./helperfunctions.sh

# Paketlisten erneuern
echo "Paketlisten erneuern ..."
mache "aptitude update"

# Pakete aktualisieren
echo "Pakete aktualisieren ..."
if [ $Y -eq 1 ]; then
 mache "aptitude full-upgrade -y"
elif [ $Y -eq 0 ]; then
 mache "aptitude full-upgrade"
else 
 fehler 
fi

# FIXME: sollte beim Erscheinen von 16.04 nicht mehr
# notwendig sein.
# nicht aufzulösende Abhängigkeiten führen zu einem Fehler
# vermutlich weil alpha-Version
echo "Führe apt-get -f aus ..."
if [ $Y -eq 1 ]; then
  mache "apt-get -f install -y"
elif [ $Y -eq 0 ]; then
  mache "apt-get -f install"
else
  fehler
fi

#########################
# Software installieren #
#########################
# Greenfoot
echo "Lade Greenfoot herunter ..."
if $( wget --quiet http://www.greenfoot.org/download/files/Greenfoot-linux-302.deb ); then
  echo -e "... fertig\n"
  echo "Installiere Greenfoot ..."
  # Greenfoot sucht in /usr/lib/jvm nach java, statt Umgebungsvariablen zu nutzen.
  mache dpkg -i Greenfoot-linux-302.deb
  rm "Greenfoot-linux-302.deb"
  sed -i 's/^Categories.*$/Categories=Application;itg;informatik;/' /usr/share/applications/greenfoot.desktop
  sed -i 's/.*bluej.language=english.*$/#bluej.language=english/' /usr/share/greenfoot/greenfoot.defs
  sed -i 's/.*bluej.language=german.*$/bluej.language=german/' /usr/share/greenfoot/greenfoot.defs
else
  fehler
fi

# BlueJ
echo "Lade BlueJ herunter ..."
if $( wget --quiet http://www.bluej.org/download/files/bluej-316.deb ); then
  echo -e "... fertig\n"
  echo "Installiere BlueJ ..."
  mache "dpkg -i bluej-316.deb"
  rm bluej-316.deb
  sed -i 's/^Categories.*$/Categories=Application;itg;informatik;/' /usr/share/applications/bluej.desktop
  sed -i 's/.*bluej.language=english.*$/#bluej.language=english/' /usr/share/bluej/bluej.defs
  sed -i 's/.*bluej.language=german.*$/bluej.language=german/' /usr/share/bluej/bluej.defs
else
  fehler
fi

# Blufish
echo "Installiere Bluefish ..."
installiere "bluefish"
echo "Konfiguriere Bluefish ..."
sed -i 's/^Categories.*$/Categories=Application;itg;informatik;/' /usr/share/applications/bluefish.desktop
echo -e "... fertig.\n"

# Scratch
echo "Installiere Scratch ..."
installiere "scratch"
echo "Konfiguriere Scratch ..."
sed -i 's/^Categories.*$/Categories=Application;itg;/' /usr/share/applications/scratch.desktop
sed -i 's/^Categories.*$/Categories=Application;itg;/' /usr/share/applications/squeak.desktop
echo -e "... fertig.\n"

# TigerJython
echo "Lade TigerJython herunter ..."
if $( wget --quiet http://jython.tobiaskohn.ch/tigerjython2.jar ); then
  echo -e "... fertig\n"
  echo "Installiere TigerJython ..."
  if [ -e /opt/tigerjython/ ]; then
    rm -r /opt/tigerjython/
    mkdir /opt/tigerjython/
    mv tigerjython2.jar /opt/tigerjython/tigerjython2.jar 
  else 
    mkdir /opt/tigerjython/
    mv tigerjython2.jar /opt/tigerjython/tigerjython2.jar 
  fi
  cp dateien/desktops/tigerjython.desktop /usr/share/applications
  cp dateien/icons/tigerjython-* /usr/share/pixmaps
else
  fehler
fi

# Libre Ofice Base
installiere "libreoffice-base"
sed -i 's/^Categories.*$/Categories=Office;Database;X-Red-Hat-Base;X-MandrivaLinux-MoreApplications-Databases;itg;informatik;/' /usr/share/applications/libreoffice-base.desktop

# Hamstersimulator 
#echo "Lade Hamster-Simulator herunter ..."
#if $( wget --quiet http://www.boles.de/hamster/download/v29/hamstersimulator-v29-03-java8.zip ); then
#  echo -e "... fertig\n"
#  unzip hamstersimulator-v29-03-java8.zip
#  rm hamstersimulator-v29-03-java8.zip
#  echo "Installiere Hamstersimulator ..."
#  if [ -e /opt/hamstersimulator ]; then
#    rm -r /opt/hamstersimulator
#    mv hamstersimulator-v29-03-java8 /opt/hamstersimulator
#  else
#    mv hamstersimulator-v29-03-java8 /opt/hamstersimulator
#  fi
#  cp dateien/desktops/hamstersimulator.desktop /usr/share/applications
#  cp dateien/icons/hamstersimulator-* /usr/share/pixmaps
#  echo -e "... fertig.\n"
#else
#  fehler
#fi

# PdfShuffler
echo "Installiere PdfShuffler"
installiere "pdfshuffler"

# Gimp
echo "Installiere Gimp ..."
installiere "gimp gimp-help-de gimp-ufraw"
sed -i 's/^Categories.*$/Categories=Graphics;2DGraphics;RasterGraphics;GTK;bk;/' /usr/share/applications/gimp.desktop


# Zeichentabelle 
sed -i 's/^Categories.*$/Categories=GNOME;GTK;Utility;itg;/' /usr/share/applications/gucharmap.desktop

#Libre Office Writer
sed -i 's/^Categories.*$/Categories=Office;WordProcessor;X-Red-Hat-Base;X-MandrivaLinux-Office-Wordprocessors;itg;/' /usr/share/applications/libreoffice-writer.desktop

#Libre Office Draw
sed -i 's/^Categories.*$/Categories=Office;FlowChart;Graphics;2DGraphics;VectorGraphics;X-Red-Hat-Base;X-MandrivaLinux-Office-Drawing;bk;itg;/' /usr/share/applications/libreoffice-draw.desktop

# Java Mission Control
sed -i 's/^Categories.*$/Categories=informatik;/' /usr/share/applications/JB-mission-control-jdk8.desktop

aufraeumen

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil4.sh aufrufen."
