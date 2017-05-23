#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Looking for updates"
wget -O /tmp/package.txt 'http://chipinstaller.damianvila.com/package.txt'
cat /tmp/package.txt | head -1 > /tmp/version
cat /tmp/package.txt | tail -1 > /tmp/link
(diff /tmp/version /home/chip/.CHIPinstaller/.version && echo 'Already up-to-date.') || exec ./headlessupdate.sh

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
if hash lynx 2>/dev/null; then
  P4="Already installed (lynx)"
else
  P4="lynx"
fi
if hash tmux 2>/dev/null; then
  P5="Already installed (tmux)"
else
  P5="tmux"
fi
if hash git 2>/dev/null; then
  P6="Already installed (git)"
else
  P6="git"
fi

whiptail --msgbox "CHIPinstaller ready, select with spacebar" 8 78

whiptail --title "CHIPinstaller" --checklist --separate-output "Choose:" 20 78 15 \
"$P1" "" off \
"$P2" "" off \
"$P3" "" off \
"$P4" "" off \
"$P5" "" off \
"$P6" "" off 2>results

while read choice
  do
    case $choice in		
      $P1) HL_Installers/guacamole.sh
      ;;
      $P2) HL_Installers/owncloud.sh
      ;;
      $P3) HL_Installers/vim.sh
      ;;
      $P4) HL_Installers/lynx.sh
      ;;
      $P5) HL_Installers/tmux.sh
      ;;
      $P6) HL_Installers/git.sh
    esac
  echo "Closing CHIPinstaller, see you soon!"
done < results
