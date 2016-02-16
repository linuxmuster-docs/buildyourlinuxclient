#!/bin/bash
# Installationsskript Teil 2
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
# FIXME: notwendig sein.
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

# überflüssige Ordner löschen
echo "Lösche überflüssige Ordner ..."
for i in $( echo "
Bilder
Dokumente
Downloads
Musik
Öffentlich
Videos
Vorlagen
") ; do
 if [ -e /home/$ICH/$i ] ; then
   rm -r /home/$ICH/$i
 fi ; done
echo -e "... fertig\n"

# Apport ausschalten (Fehlerberichte)
echo "Senden von Fehlerberichten deaktivieren ..."
sed -i 's/^enabled.*$/enabled=0/' /etc/default/apport
echo -e "...fertig.\n"

# FIXME: Dekativiere blueman-apllet (stürzt immer ab)
echo "Deaktviere Autostart des Blueman-Applet ..."
if [ -e /etc/xdg/autostart/blueman.desktop ]; then
  rm /etc/xdg/autostart/blueman.desktop
  echo -e "... fertig.\n"
else
  echo -e "... war bereits deaktiviert.\n"
fi

echo "Ubuntu-MATE-Welcome für $ICH deaktivieren ..."
if [ -e  /home/$ICH/.config/autostart/ubuntu-mate-welcome.desktop ]; then
  rm /home/$ICH/.config/autostart/ubuntu-mate-welcome.desktop
  echo -e "... fertig.\n"
else 
  echo -e "... war bereits deaktiviert.\n"
fi

echo "Ubuntu-MATE-Welcome systemweit deaktivieren ..."
# FIXME: scheint nicht zu funktionieren
if [ -e  /etc/skel/.config/autostart/ubuntu-mate-welcome.desktop ]; then
  rm /etc/skel/.config/autostart/ubuntu-mate-welcome.desktop
  echo -e "... fertig.\n"
else 
  echo -e "... war bereits deaktiviert.\n"
fi
# linuxmuster-client-shares installieren
echo "Installiere linuxmuster-client-shares ..."
installiere "linuxmuster-client-shares"

# linuxmuster-client-profile installieren
echo "Installiere linuxmuster-client-profile ..."
installiere "linuxmuster-client-profile"

# Auf dem Schreibtisch soll das Tauschverzeichnis angezeigt werden
echo "Lege Link \"Tauschverzeichnis\" auf Schreibtisch ..." 
if [ $(grep -c "# Links nach Schreibtisch" /etc/linuxmuster-client/shares/links.conf) -eq 0 ]; then
  echo -e "\n# Links nach Schreibtisch" >> /etc/linuxmuster-client/shares/links.conf
fi

if [ $(grep -c "HOMEDIR/Tausch_auf_Server:/HOMEDIR/Schreibtisch/Tausch_auf_Server" /etc/linuxmuster-client/shares/links.conf) -eq 0 ]; then
  echo "HOMEDIR/Tausch_auf_Server:/HOMEDIR/Schreibtisch/Tausch_auf_Server" >> /etc/linuxmuster-client/shares/links.conf
 echo -e "... fertig\n"
else
  echo -e "... Link ist bereits vorhanden\n"
fi

# Anpassen der Grundeinstellungen
echo "Passe Grundeinstellungen an ..."
cp dateien/zz_10_basics.gschema.override /usr/share/glib-2.0/schemas
# Binärkonfigurationsdatei erzeugen
glib-compile-schemas /usr/share/glib-2.0/schemas/
echo -e "... fertig.\n"

# Anpassen der Panels (Leiste oben und unten)
# in der layout-Datei stehen die Plugins und ihre Anordnung
echo "Passe die Panels an ..."
cp dateien/lmn.layout /usr/share/mate-panel/layouts
# linuxmuster soll statt ubuntu-mate das default panel sein
# siehe: https://developer.gnome.org/gio/stable/glib-compile-schemas.html
# Ubuntu verwendet falsche Dateinamen für die overrides
cp dateien/zz_20_panel.gschema.override /usr/share/glib-2.0/schemas
# Binärkonfigurationsdatei erzeugen
glib-compile-schemas /usr/share/glib-2.0/schemas/
# linuxmuster als layout aktivieren
su - $ICH -c "dbus-launch gsettings set org.mate.panel default-layout 'lmn'"
# Starte das neue erstellte Mate-Panel
su - $ICH -c "killall mate-panel"
su - $ICH -c "dbus-launch dconf reset -f /org/mate/panel/objects/"
su - $ICH -c "dbus-launch dconf reset -f /org/mate/panel/toplevels/"
su - $ICH -c "mate-panel --layout lmn --reset"
su - $ICH -c "mate-panel --reset"
killall mate-panel
echo -e "... fertig.\n"


# Anpassen des Anwendungsmenüs
echo "Passe Anwendungsmenü an ..."
cp dateien/menu/mate-applications.menu /etc/xdg/menus/
for i in dateien/menu/faecher*; do
  cp $i /usr/share/mate/desktop-directories
done
for i in dateien/menu/icons/*; do
  cp $i /usr/share/pixmaps
done
echo -e "... fertig.\n"

##########################
# Programme installieren #
##########################
# Oracle Java 8
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/oracle.list
echo "Schlüssel herunterladen und hinzufügen"
mache "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EEA14886" > /dev/null
echo "Paketlisten erneuern"
mache "aptitude update"

echo "Akzeptiere Lizens"
mache "echo 'oracle-java8-installer shared/acctepted-oracle-v1-1 select true' | debconf-set-selections"

echo "Installiere Oracle Java 8 JDK"
installiere "oracle-java8-installer"

sed -i 's/^Categories.*$/Categories=informatik;/' /usr/share/applications/JB-mission-control-jdk8.desktop   
echo "Richte das Alternativen-System ein ..."
  echo "Pfad zu java vorbereiten ..."
    mache update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/jre/bin/java 1
  echo "Pfad zu javac vorbereiten ..."
    mache "update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/java 1"
  echo "Pfad zu javaws vorbereiten ..."
    mache "update-alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/java-8-oracle/bin/javaws 1"
  echo "Pfad zu jar vorbereiten ..."
    mache "update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/java-8-oracle/bin/jar 1" 
  
echo "Konfiguriere Alternativen-System ..."
  echo "Pfad zu java setzen ..."
    mache "update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java"
  echo "Pfad zu javac setzen ..."
    mache "update-alternatives --set javac /usr/lib/jvm/java-8-oracle/bin/javac"
  echo "Pfad zu javaws setzen ..."
    mache "update-alternatives --set javaws /usr/lib/jvm/java-8-oracle/bin/javaws"
  echo "Pfad zu jar setzen ..."
    mache "update-alternatives --set jar /usr/lib/jvm/java-8-oracle/bin/jar"
  
echo "Setze Umgebungsvariablen für Java ..."
if [ -e /etc/X11/Xsession.d/90environment ]; then
  rm /etc/X11/Xsession.d/90environment
fi
echo "export export=J2SDKDIR=/usr/lib/jvm/java-8-oracle" >> /etc/X11/Xsession.d/90environment
echo "export J2REDIR=/usr/lib/jvm/java-8-oracle" >> /etc/X11/Xsession.d/90environment
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/X11/Xsession.d/90environment
echo "export DERBY_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/X11/Xsession.d/90environment
echo -e "...fertig.\n"

echo "Bereite Browser-Java-Plugin vor ..."
  mache "update-alternatives --install /usr/lib/mozilla/plugins/mozilla-javaplugin.so mozilla-javaplugin.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/libnpjp2.so 1"
echo "Richte Browser-Java-Plugin ein ..."
  mache "update-alternatives --set mozilla-javaplugin.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/libnpjp2.so" 

aufraeumen

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil3.sh aufrufen."
