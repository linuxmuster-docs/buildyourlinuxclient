#!/bin/bash

# Prüfen, ob das Skript mir root-Rechten aufgerufen wurde
if [ `id -u` != 0 ]; then
    echo "Bitte rufen Sie dieses Skript mit root-Rechten auf"
    exit 1
fi

# Loggen vorbereiten
LOGDATEI=./install.log

if [ -e LOGDATEI ]; then
  rm "$LOGDATEI"
fi

# Funktionen dazuladen
. functions.sh

# Paramter auslesen
# prinzipiell wird alles in die Logdatei
# mit -v oder --verbose werden alle MEldungen auch StOut ausgegeben
V=0
# mit -y oder --yes werden alle Fragen mit y beantwortet
Y=0
# mit -i oder --interactive werden debconf-Dialoge gezeigt, anderen-
#    falls werden im Skript gesetzt Werte verwendet
I=0

usage="Dieses Skript installiert ...i sdsddsdd"
while getopts "iyv" options; do
  case $options in
    i ) I=1;;
    y ) Y=1;;
    v ) V=1;;
    h ) echo $usage
        exit 0
        ;;
   \? ) echo $usage
        exit 1
        ;;
  esac
done


if [ $I -eq 0 ]; then
  export DEBIAN_FRONTEND=noninteractive
elif [ $I -eq 1 ]; then
  export DEBIAN_FRONTEND=dialog
else
  fehler
fi

if [ $V -eq 0 ] && [ $Y -eq 0 ]; then
 echo "Bitte mit -y starten" ; exit 1
fi

if [ $I -eq 1 ] && [ $Y -eq 1 ] && [ $V -eq 0 ]; then
  echo "Die Schalter -i und -y können nur kombiniert werden, wenn auch der Schalter -v benutzt wird"
  exit
fi

# Ausgabe auf Konsole und in log-Datei
exec &> >(tee -a "$LOGDATEI")

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

su $(who am i | cut -d ' ' -f1) -m -c "gsettings set org.gnome.SessionManager logout-prompt false" 

# Anpassen der Panels (Leiste oben und unten)
# in der layout-Datei stehen die Plugins und ihre Anordnung
echo "Passe die Panels an ..."
cp dateien/lmn.layout /usr/share/mate-panel/layouts
# linuxmuster soll statt ubuntu-mate das default panel sein
# siehe: https://developer.gnome.org/gio/stable/glib-compile-schemas.html
# Ubuntu verwendet falsche Dateinamen für die overrides
cp dateien/zz_10_panel.gschema.override /usr/share/glib-2.0/schemas
# Binärkonfigurationsdatei erzeugen
glib-compile-schemas /usr/share/glib-2.0/schemas/
# linuxmuster als layout aktivieren
su $(who am i | cut -d ' ' -f1) -m -c "gsettings set org.mate.panel default-layout 'lmn'"
# Starte das neue erstellte Mate-Panel
su $(who am i | cut -d ' ' -f1) -m -c "killall mate-panel"
su $(who am i | cut -d ' ' -f1) -m -c "dconf reset -f /org/mate/panel/objects/"
su $(who am i | cut -d ' ' -f1) -m -c "dconf reset -f /org/mate/panel/toplevels/"
su $(who am i | cut -d ' ' -f1) -m -c "mate-panel --layout lmn --reset"
su $(who am i | cut -d ' ' -f1) -m -c "mate-panel --reset"
echo -e "... fertig.\n"

echo "Lösche Paket-Cache ..."
mache "aptitude clean"

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil2.sh aufrufen."
