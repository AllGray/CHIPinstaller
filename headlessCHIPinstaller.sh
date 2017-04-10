#!/bin/bash

if test -f /etc/guacamole/guacamole.properties; then
  P1="Already installed (Guacamole)"
else
  P1="Guacamole"
fi
if test -f /var/www/owncloud/AUTHORS; then
  P2="Already installed (Owncloud)"
else
  P2="Owncloud"
fi
if hash vim 2>/dev/null; then
  P3="Already installed (VIM)"
else
  P3="VIM"
fi
if hash tightvncserver 2>/dev/null; then
  P4="Already installed (TightVNC)"
else
  P4="TightVNC"
fi
if hash surf 2>/dev/null; then
  P5="Already installed (surf)"
else
  P5="surf"
fi
if hash tmux 2>/dev/null; then
  P6="Already installed (tmux)"
else
  P6="tmux"
fi
if hash git 2>/dev/null; then
  P7="Already installed (git)"
else
  P7="git"
fi

whiptail --title "CHIPinstaller" --checklist --separate-output "Choose:" 20 78 15 \
"$P1" "" off \
"$P2" "" off \
"$P3" "" off \
"$P4" "" off \
"$P5" "" off \
"$P6" "" off \
"$P7" "" off 2>results

while read choice
  do
    case $choice in		
      $P1) Installers/guacamole.sh
      ;;
      $P2) Installers/owncloud.sh
      ;;
      $P3) Installers/vim.sh
      ;;
      $P4) Installers/tightvnc.sh
      ;;
      $P5) Installers/surf.sh
      ;;
      $P6) Installers/tmux.sh
      ;;
      $P7) Installers/git.sh
    esac
  echo "Closing CHIPinstaller, see you soon!"
done < results
