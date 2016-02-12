#!/bin/bash

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
