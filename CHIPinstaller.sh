#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Update the repos
apt-get -y update

echo "Welcome to CHIPinstaller"

echo "Looking for updates"
wget -O /tmp/package.txt 'http://chipinstaller.damianvila.com/package.txt'
cat /tmp/package.txt | head -1 > /tmp/version
cat /tmp/package.txt | tail -1 > /tmp/link
(diff /tmp/version /home/chip/.CHIPinstaller/.version && echo 'Already up-to-date.') || exec ./update.sh


if hash zenity 2>/dev/null; then
  :
else
  apt-get install -y zenity
fi
if hash jq 2>/dev/null; then
  :
else
 apt-get install -y jq
fi
if hash yad 2>/dev/null; then
  :
else
  echo "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" | tee -a /etc/apt/sources.list
  wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  echo "#key added" | tee -a /etc/apt/sources.list
  apt-get -y update
  apt-get install -y yad
fi
if grep -Fxq "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" /etc/apt/sources.list && grep -Fxq "#key added" /etc/apt/sources.list; then
  :
else
  wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  apt-get update
  echo "#key added" | tee -a /etc/apt/sources.list
fi

if test -f /etc/guacamole/guacamole.properties; then
  :
else
  P1="Guacamole|GUI_Installers/guacamole.sh"
fi
if test -f /var/www/owncloud/AUTHORS; then
  :
else
  P2="Owncloud|GUI_Installers/owncloud.sh"
fi
if hash vim 2>/dev/null; then
  :
else
  P3="VIM|GUI_Installers/vim.sh"
fi
if hash tightvncserver 2>/dev/null; then
  :
else
  P4="TightVNC|GUI_Installers/tightvnc.sh"
fi
if hash surf 2>/dev/null; then
  :
else
  P5="surf|GUI_Installers/surf.sh"
fi
if hash tmux 2>/dev/null; then
  :
else
  P6="tmux|GUI_Installers/tmux.sh"
fi
if hash git 2>/dev/null; then
  :
else
  P7="git|GUI_Installers/git.sh"
fi

menu=($P1 $P2 $P3 $P4 $P5 $P6 $P7)

zenity --info --text="Warning, some tools need user input, pay attention while installing"

yad_opts=(--form
--scroll
--text="Install Software"
--image="icon.png"
--button="Install" --button="Exit")

for m in "${menu[@]}"
do
yad_opts+=( --field="${m%|*}:CHK" )
done

IFS='|' read -ra ans < <( yad "${yad_opts[@]}" )

for i in "${!ans[@]}"
do
if [[ ${ans[$i]} == TRUE ]]
then
m=${menu[$i]}
name=${m%|*}
cmd=${m#*|}
echo "selected: $name ($cmd)"
$cmd
fi
done

echo "Closing CHIPinstaller, see you soon!"
sleep 3
kill -9 $PPID
