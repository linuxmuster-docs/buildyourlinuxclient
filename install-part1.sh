#!/bin/bash
# Installationsskript Teil 1
#
# linuxmuster@gymneureut.de
# 2.02.2016
# GPL v3
#

. ./helperfunctions.sh

# FIXME
# bug 1542549
# Ubuntu MATE alpha2 liefert eine kaputte init-system-helpers
# Version aus (1.6ubuntu1)
# Nach endgültigem Release entfernen

echo "Behandle BUG 1542549"
echo "Init-Sytem anpassen, Teil 1 ..."
mache "update-rc.d mountkernfs.sh defaults"
echo "Init-Sytem anpassen, Teil 2 ..."
mache "update-rc.d dbus defaults"
echo "Führe apt-get -f install aus ..."
mache "apt-get -f install"


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

# alte Signaturschlüssel löschen
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
    # FIXME: zu gegebener Zeit ändern
    echo "deb http://pkg.linuxmuster.net/ trusty/" > /etc/apt/sources.list.d/linuxmuster-client.list
    #echo "deb http://pkg.linuxmuster.net/ xenial/" > /etc/apt/sources.list.d/linuxmuster-client.list
    echo -e "... fertig\n"
  fi
else 
  fehler
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
  echo "ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=linuxmuster-net,dc=lokal" | debconf-set-selections
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
  echo "linuxmuster-client-auth shared/ldapns/base-dn string dc=linuxmuster-net,dc=lokal" | debconf-set-selections
  echo -e "... fertig\n"
fi 

echo "Installiere linuxmuster-client-auth ..."
installiere "linuxmuster-client-auth"


aufraeumen

echo "Bitte rebooten. Unsynchronisiert starten. Danach install-teil2.sh aufrufen."
