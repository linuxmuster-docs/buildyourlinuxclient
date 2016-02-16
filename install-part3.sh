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

# Hamstersimulator
echo "Lade Hamster-Simulator herunter ..."
if $( wget --quiet http://www.boles.de/hamster/download/v29/hamstersimulator-v29-03-java8.zip ); then
  echo -e "... fertig\n"
  mache "unzip  hamstersimulator-v29-03-java8.zip"
  rm hamstersimulator-v29-03-java8.zip
  echo "Installiere Hamstersimulator ..."
  if [ -e /opt/hamstersimulator ]; then
    rm -r /opt/hamstersimulator
    mv hamstersimulator-v29-03-java8 /opt/hamstersimulator
  else
    mv hamstersimulator-v29-03-java8 /opt/hamstersimulator
  fi
  cp dateien/desktops/hamstersimulator.desktop /usr/share/applications
  cp dateien/icons/hamstersimulator-* /usr/share/pixmaps
  echo -e "... fertig.\n"
else
  fehler
fi

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

# PdfShuffler
echo "Installiere PdfShuffler"
installiere "pdfshuffler"

# Gimp
echo "Installiere Gimp ..."
installiere "gimp gimp-help-de gimp-ufraw"
sed -i 's/^Categories.*$/Categories=Graphics;2DGraphics;RasterGraphics;GTK;bk;/' /usr/share/applications/gimp.desktop

# Libreoffice Draw
echo "Installiere LibreOffice Draw ..."
installiere "libreoffice-draw"

# LibreOffice Draw
# Achtung: dieser Eintrag steht hier nur vorsorglich
# MATE nutzt für libreoffice-draw und -math angepasste Datein
# siehe Pakete: ubuntu-mate-libreoffice-draw-icos
# die Desktop-Datei liegt dann in /usr/share/mate/applications
# eine Anpassung der Kategegorie dort bringt nichts
# Lösung: direktes Einnfügen von Draw und Math in der Datei
# /etc/xdg/menu/mate-application.menu
sed -i 's/^Categories.*$/Categories=Graphics;Office;FlowChart;Graphics;2DGraphics;VectorGraphics;X-Red-Hat-Base;X-MandrivaLinux-Office-Drawing;bk;itg;/' /usr/share/applications/libreoffice-draw.desktop

# LibreOffice Math
echo "Installiere LibreOffice Draw ..."
installiere "libreoffice-math"

# Beachte Hinweis bei LibreOffice Draw
sed -i 's/^Categories.*$/Categories=Office;FlowChart;Graphics;2DGraphics;VectorGraphics;X-Red-Hat-Base;X-MandrivaLinux-Office-Drawing;mathematik;/' /usr/share/applications/libreoffice-draw.desktop

# kwordquiz
echo "Installiere kwordquiz ..."
installiere "kwordquiz"
sed -i 's/^Categories.*$/Categories=Qt;KDE;Languages;englisch;franzoesisch;/' /usr/share/applications/org.kde.kwordquiz.desktop

# alte Signaturschlüssel löschen
echo "Lösche alte Schlüsseldatei ..."
if [ -e "http://www.geogebra.net/linux/office@geogebra.org.gpg.key" ]; then
  mache "http://www.geogebra.net/linux/office@geogebra.org.gpg.key"
else
  echo -e "... fertig\n"
fi

# Signatur-Schlüssel herunterladen
echo "Lade Signatur-Schlüssel herunter ..."
if $( wget --quiet http://www.geogebra.net/linux/office@geogebra.org.gpg.key ); then
  echo -e "... fertig\n"
  # Schlüssel einspielen
  echo "Spiele Schlüssel ein ..."
  if mache "apt-key add office@geogebra.org.gpg.key"; then
    # Repository eintragen
    echo "Trage Repository ein ..."
    echo "deb http://www.geogebra.net/linux/ stable main" > /etc/apt/sources.list.d/geogebra.list
    echo -e "... fertig\n"
  fi
else
  fehler
fi

# Schlüssel wieder löschen
echo "Lösche Schlüsseldatei wieder ..."
if [ -e "office@geogebra.org.gpg.key" ]; then
  mache "rm office@geogebra.org.gpg.key"
fi

# Paketlisten erneuern
echo "Paketlisten erneuern ..."
mache "aptitude update"

# Geogebra installieren
echo "Installiere Geogebra ..."
installiere geogebra5

# Konfiguriere Geogebra
echo "Konfiguriere Geogebra ..."
if [ ! -d /home/$ICH/.config/geogebra ]; then
  mkdir /home/$ICH/.config/geogebra
fi
echo "user_login_skip=true" >> /home/$ICH/.config/geogebra/geogebra.properties
sed -i 's/^Categories.*$/Categories=mathematik;/' /usr/share/applications/geogebra.desktop
echo -e "... fertig.\n"

# wxMaxima 
echo "Installiere wxMaxima ..."
installiere wxmaxima
sed -i 's/^Categories.*$/Categories=X-Red-Hat-Base;X-Red-Hat-Base-Only;mathematik;/' /usr/share/applications/wxMaxima.desktop
echo "ShowTips=0" > /home/$ICH/.wxMaxima 

# Audacity
echo "Installiere Audacity ..."
installiere audacity
sed -i 's/^Categories.*$/Categories=AudioVideo;Audio;AudioVideoEditing;musik;/' /usr/share/applications/audacity.desktop
if [ -e /home/$ICH/.audacity-data ]; then
  rm -r /home/$ICH/.audacity-data
fi
mkdir /home/$ICH/.audacity-data
echo "[GUI]" > /home/$ICH/.audacity-data/audacity.cfg
echo "ShowSplashScreen=0" >> /home/$ICH/.audacity-data/audacity.cfg
chown -R $ICH:$ICH /home/$ICH/.audacity-data

# Denemo
echo "Installiere denemo ..."
installiere "denemo denemo-doc"
sed -i 's/^Categories.*$/Categories=GNOME;musik;/' /usr/share/applications/denemo.desktop

# Eagle
echo "Lade Eagle herunter ..."
if $( wget --quiet http://web.cadsoft.de/ftp/eagle/program/7.5/eagle-lin64-7.5.0.run ); then
  echo -e "... fertig\n"
  echo "Installiere Eagle ..." 
  mache "sh eagle-lin64-7.5.0.run /opt"
  rm eagle-lin64-7.5.0.run
  mv /opt/eagle-7.5.0 /opt/eagle
  cp dateien/desktops/eagle.desktop /usr/share/applications/
  cp /opt/eagle/bin/eagleicon50.png /usr/share/pixmaps
  echo 'CheckForUpdate.Auto = "0"' > /home/$ICH/.eaglerc
else
  fehler
fi

# Oregano
echo "Installiere Oregano ..."
installiere oregano
sed -i 's/^Categories.*$/Categories=GNOME;nwt;physik;/' /usr/share/applications/oregano.desktop

# Stellarium
echo "Installiere Stellarium ..."
installiere "stellarium"
sed -i 's/^Categories.*$/Categories=GNOME;nwt;physik;/' /usr/share/applications/stellarium.desktop

# Openshot
echo "Installiere Openshot ..."
installiere openshot

# Inkscape
echo "Installiere Inkscape ..."
installiere inkscape

# Scribus
echo "Installiere Scribus ..."
installiere scribus

# Veusz
echo "Bereite Veusz-Installation vor ..."
echo "deb http://ppa.launchpad.net/jeremysanders/ppa/ubuntu vivid main" > /etc/apt/sources.list.d/veusz.list
# FIXME: ersetzen, sobald verfügbr
#echo "deb http://ppa.launchpad.net/jeremysanders/ppa/ubuntu xenial main" > /etc/apt/sources.list.d/veusz.list
echo -e "... fertig\n"
echo "Schlüssel herunterladen und hinzufügen ..."
mache "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 9D5904BC" > /dev/null
echo "Paketlisten erneuern"
mache "aptitude update"

echo "Installiere Veusz ..."
installiere veusz

sed -i 's/^Categories.*$/Categories=mathematik;physik;nwt;/' /usr/share/applications/veusz.desktop

if [ -e /home/$ICH/.veusz.org ]; then
  rm -r /home/$ICH/.veusz.org
fi
mkdir /home/$ICH/.veusz.org
cp dateien/veusz.conf /home/$ICH/.veusz.org/


# Zeichentabelle 
sed -i 's/^Categories.*$/Categories=GNOME;GTK;Utility;itg;/' /usr/share/applications/gucharmap.desktop

#Libre Office Writer
sed -i 's/^Categories.*$/Categories=Office;WordProcessor;X-Red-Hat-Base;X-MandrivaLinux-Office-Wordprocessors;itg;/' /usr/share/applications/libreoffice-writer.desktop

# Java Mission Control
sed -i 's/^Categories.*$/Categories=informatik;/' /usr/share/applications/JB-mission-control-jdk8.desktop

aufraeumen

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil4.sh aufrufen."
