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

fehler() {
  echo -e "\033[31m... FEHLER\033[0m\n"
}

mache() {
if [ $V -eq 1 ]; then
  $* && echo -e "... fertig\n" || fehler
else 
  $* >> "$LOGDATEI" && echo -e "... fertig\n" || fehler
fi
}

if [ $I -eq 1 ] && [ $Y -eq 1 ] && [ $V -eq 0 ]; then
  echo "Die Schalter -i und -y können nur kombiniert werden, wenn auch der Schalter -v benutzt wird"
  exit
fi

installiere() {
if [ $V -eq 1 ] && [ $Y -eq 1 ]; then
  aptitude install -y $* && echo -e "... fertig\n" || fehler
elif [ $V -eq 1 ] && [ $Y -eq 0 ]; then
  aptitude install $* && echo -e "... fertig\n" || fehler
elif [ $V -eq 0 ] && [ $Y -eq 1 ]; then
  aptitude install -y $* >> "$LOGDATEI" && echo -e "... fertig\n" || fehler
elif [ $V -eq 0 ] && [ $Y -eq 0 ]; then
  aptitude install $* >> "$LOGDATEI" && echo -e "... fertig\n" || fehler
else
  fehler
fi
}

# Ausgabe auf Konsole und in log-Datei
exec &> >(tee -a "$LOGDATEI")

# Paketlisten erneuern
echo "Paketlisten erneuern ..."
mache "apt-get update"

# Pakete aktualisieren
echo "Pakete aktualisieren ..."
if [ $Y -eq 1 ]; then
 mache "apt-get dist-upgrade -y"
elif [ $Y -eq 0 ]; then
 mache "apt-get dist-upgrade"
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

# aptitude installieren
echo "Installiere aptitude ..."
if [ $Y -eq 1 ]; then
  mache "apt-get install aptitude -y"
elif [ $Y -eq 0 ]; then
  mache "apt-get install aptitude"
else
  fehler
fi

# vim installieren
echo "Installiere vim ..."
installiere "vim"

# alte Signaturschlüssellöschen
echo "Lösche alte Schlüsseldatei ..."
if [ -e "linuxmuster.net.key" ]; then
  mache "rm linuxmuster.net.key"
else 
  echo -e "... fertig\n"
fi

# Signatur-Schlüssel herunterladen
echo "Lade Signatur-Schlüssel herunter ..."
if $( wget --quiet http://pkg.linuxmuster.net/linuxmuster.net.key ); then
  echo -e "... fertig\n"
  # Schlüssel einspielen
  echo "Spiele Schlüssel ein ..."
  if mache "apt-key add linuxmuster.net.key"; then
    # Repository eintragen
    echo "Trage Repository ein ..."
    echo "deb http://pkg.linuxmuster.net/ trusty/" > /etc/apt/sources.list.d/linuxmuster-client.list
    # zu gegebener Zeit ändern
    #echo "deb http://pkg.linuxmuster.net/ xenial/" > /etc/apt/sources.list.d/linuxmuster-client.list
    echo -e "... fertig\n"
  fi
#else 
 # fehler
fi

# Schlüssel wieder löschen
echo "Lösche Schlüsseldatei wieder ..."
if [ -e "linuxmuster.net.key" ]; then
  mache "rm linuxmuster.net.key"
fi

# Paketlisten erneuern
echo "Paketlisten erneuern ..."
mache "aptitude update"

# Abhängigkeiten für linuxmuster-client-auth installieren
echo "Installiere cifs-utils ..."
installiere "cifs-utils"
echo "Installiere rsync ..."
installiere "rsync"
echo "Installiere libpam-mount ..."
installiere "libpam-mount"
echo "Installiere nscd ..."
installiere "nscd"
# Werte siehe http://www.linuxmuster.net/wiki/dokumentation:handbuch60:clients:linuxmuster-client-auth
if [ $I -eq 0 ]; then
  # FIXME: Autokonfiguration funktioniert nicht 
  echo "Konfigurationen für ldap-auth-comfig hinterlegen"
  echo "ldap-auth-config ldap-auth-config/ldapns/ldap-server string	ldapi:///" | debconf-set-selections
  echo "ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=gymneureut,dc=local" | debconf-set-selections
  echo "ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3" | debconf-set-selections
  echo "ldap-auth-config ldap-auth-config/dbrootlogin boolean false" | debconf-set-selections
  echo "ldap-auth-config ldap-auth-config/dblogin boolean false" | debconf-set-selections
  echo -e "... fertig\n"
fi 

echo "Installiere libnss-ldap ..."
installiere "libnss-ldap"

echo "Installiere libpam-ldap ..."
installiere "libpam-ldap"

if [ $I -eq 0 ]; then
  # FIXME: Autokonfiguration funktioniert nicht
  echo "Hinterlege Konfigurationsdateien für linuxmuster-client-auth"
  echo "linuxmuster-client-auth shared/ldapns/ldap-server string 10.16.1.1" | debconf-set-selections
  echo "linuxmuster-client-auth shared/ldapns/base-dn string dc=gymneureut,dc=local" | debconf-set-selections
  echo -e "... fertig\n"
fi 

echo "Installiere linuxmuster-client-auth ..."
installiere "linuxmuster-client-auth"

echo "Lösche Paket-Cache ..."
mache "aptitude clean"

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil2.sh aufrufen."
