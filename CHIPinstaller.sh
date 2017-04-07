#!/bin/bash

cd ~/CHIPinstaller

#sudo rm -R -f log.txt
echo "Welcome to CHIPinstaller" | sudo tee log.txt

sudo chmod 777 log.txt
exec &> >(tee -a log.txt)

sudo apt-mark hold -qq  pocket-home

if hash zenity 2>/dev/null; then
  :
else
  sudo apt-get update
  sudo apt-get install -y zenity
fi
if hash jq 2>/dev/null; then
  :
else
 sudo apt-get update 
 sudo apt-get install -y jq
fi
if hash yad 2>/dev/null; then
  :
else
  echo "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" | sudo tee -a /etc/apt/sources.list
  sudo wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  sudo dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  echo "#key added" | sudo tee -a /etc/apt/sources.list
  sudo apt-get update
  sudo apt-get install -y yad
fi
if grep -Fxq "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" /etc/apt/sources.list && grep -Fxq "#key added" /etc/apt/sources.list; then
  :
else
  sudo wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  sudo dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  sudo apt-get update
  echo "#key added" | sudo tee -a /etc/apt/sources.list
fi

if hash guacamole 2>/dev/null; then
  :
else
  P1="Guacamole|Installers/guacamole.sh"
fi
if hash VIM 2>/dev/null; then
  :
else
  P2="VIM|Installers/VIM.sh"
fi
if hash VIM 2>/dev/null; then
  :
else
  P3="VIM|Installers/vim.sh"
fi
if hash TightVNC 2>/dev/null; then
  :
else
  P4="TightVNC|Installers/tightvnc.sh"
fi
if hash surf 2>/dev/null; then
  :
else
  P5="surf|Installers/surf.sh"
fi
if hash tmux 2>/dev/null; then
  :
else
  P6="tmux|Installers/tmux.sh"
fi
if hash git 2>/dev/null; then
  :
else
  P7="git|Installers/git.sh"
fi
if hash Netatalk 2>/dev/null; then
  :
else
  P8="Netatalk|Installers/netatalk.sh"
fi
menu=($P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 )

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
