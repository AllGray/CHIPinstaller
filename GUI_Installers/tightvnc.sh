#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install VNC server
apt-get -y install tightvncserver

# Check if apt-get update/install worked.
if [ $? != 0 ]
then
    echo "Make sure to run: sudo apt-get update && sudo apt-get upgrade"
    exit
fi

# Clear screen
reset

# Start info
echo "+-----------------------------------------------------------+"
echo "|                         IMPORTANT                         |"
echo "|             Set the password for your install             |"
echo "|                    And don't forget it                    |"
echo "|      For the view-only password you can just press n      |"
echo "+-----------------------------------------------------------+"

# Start the VNC server and set password
vncserver 

# Create Configuration
read -r hostname < /etc/hostname
cat >/etc/systemd/system/tightvncserver.service <<EOL
[Unit]
Description=TightVNC remote desktop server
After=sshd.service
[Service]
Type=dbus
ExecStart=/usr/bin/tightvncserver :1
User=$hostname
Type=forking
WantedBy=multi-user.target
EOL

# Give out some permissions
sudo chown root:root /etc/systemd/system/tightvncserver.service
sudo chmod 755 /etc/systemd/system/tightvncserver.service
sudo systemctl enable tightvncserver.service

# Grab Local IP address
hostname -I > local_ip.txt
read -r local_ip < local_ip.txt

# Clean up
rm -rf local_ip.txt

# Clear screen
reset

# Create Readme.txt in /home/chip
cat >/home/chip/tightVNC_README.txt <<EOL
"+------------------------------------------------------+"
"|                   Congratulation!!                   |"
"|                 Your install is done                 |"
"|  You can access the VNC server from most VNCviewers  |"
"|              Just go to $local_ip:1              |"
"|             in your prefered VNC viewers             |"
"|                                                      |"
"|                                                      |"
"|    This installer was brought to you by AllGray!!    |"
"|              And the CHIPinstaller team              |"
"+------------------------------------------------------+"
EOL


# Finishing up
echo "+------------------------------------------------------+"
echo "|                   Congratulation!!                   |"
echo "|                 Your install is done                 |"
echo "|  You can access the VNC server from most VNCviewers  |"
echo "|              Just go to $local_ip:1              |"
echo "|             in your prefered VNC viewers             |"
echo "|                                                      |"
echo "|                                                      |"
echo "|    This installer was brought to you by AllGray!!    |"
echo "|              And the CHIPinstaller team              |"
echo "+------------------------------------------------------+"
