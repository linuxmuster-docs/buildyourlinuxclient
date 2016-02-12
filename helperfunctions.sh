# Hilfsfunktionen
#
# linuxmuster@gymneureut.de
# 2.02.2016
# GPL v3
#

# Prüfen, ob das Skript mir root-Rechten aufgerufen wurde
checkroot() {
if [ `id -u` != 0 ]; then
  echo "Bitte rufen Sie dieses Skript mit root-Rechten auf"
  exit 1
else
  return 0
fi
}

# Gleich prüfen
checkroot

# Fehler aufgetreten
fehler() {
  msg="$1"
  echo -e "\033[31m... FEHLER\033[0m\n"
  if [ -z "$msg" ]; then
    echo $msg
  fi
}



# Übergabeparamter auswrten
I=0
Y=0
V=0
  usage="Diese Skripte passen ein Ubuntu-MATE für den Einsatz mit\n
         linuxmuster.net an, installieren weitere, für den Unterricht\n
         sinnvolle Programme und \"optimieren\" die graphische Oberfläche.\n
         Optionen:\n
         -y alle Fragen werden mit \"ja\" beantwortet. In Dialogfeldern\n
            werden Standardantworten gesetzt\n
         -v alle Ausgaben werden auf der Konsole ausgegeben\n
         -i interaktiv, der Nutzer kann Dialogfelder selbst ausfüllen"  
  while getopts "ivy" options; do
    case $options in
      i ) I=1;;
      y ) Y=1;;
      v ) V=1;;
      h ) echo -e $usage
          exit 1
          ;;
     \? ) echo -e $usage
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

  if [ $I -eq 1 ] && [ $Y -eq 1 ] && [ $V -eq 0 ]; then
    echo "Die Schalter -i und -y können nur kombiniert werden, wenn auch der Schalter -v benutzt wird"
    exit 1
  fi

# Führe einen Befehl aus
mache() {
  if [ $V -eq 1 ]; then
    $* && echo -e "... fertig\n" || fehler
  else
    $* >> "$LOGDATEI" && echo -e "... fertig\n" || fehler
  fi
}

# Pakete installieren
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

ICH=$(who am i | cut -d ' ' -f1)

# Logdatei
LOGDATEI=./install.log

if [ -e LOGDATEI ]; then
  rm "$LOGDATEI"
fi


# Ausgabe auf Konsole und in log-Datei
exec &> >(tee -a "$LOGDATEI")

# Aufräumen
aufraeumen () {
echo "Lösche Paket-Cache ..."
mache "aptitude clean"

echo "Papierkorb leeren ..."
if [ -e /home/$ICH/.local/share/Trash/files/ ]; then
  mache "rm -r /home/$ICH/.local/share/Trash/files/"
else
  echo -e "... war bereits leer.\n"
fi
}
