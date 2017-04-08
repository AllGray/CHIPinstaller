#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install VNC server
apt-get -y install tightvncserver

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
cat >/etc/systemd/system/tightvncserver.service <<EOL
[Unit]
Description=TightVNC remote desktop server
After=sshd.service

[Service]
Type=dbus
ExecStart=/usr/bin/tightvncserver :1
User=
Type=forking

WantedBy=multi-user.target

EOL

# Finish config
read -r hostname < /etc/hostname
sed "s/User=/User=$hostname/g" /etc/systemd/system/tightvncserver.service

# Give out some permissions
sudo chown root:root /etc/systemd/system/tightvncserver.service
sudo chmod 755 /etc/systemd/system/tightvncserver.service
sudo systemctl enable tightvncserver.service

# Clear screen
reset

# Finishing up
echo "+------------------------------------------------------+"
echo "|                   Congratulation!!                   |"
echo "|                 Your install is done                 |"
echo "|  You can access the VNC server from most VNCviewers  |"
echo "|         Just go to server.local.ip.address:1         |"
echo "|             in your prefered VNC viewers             |"
echo "|                                                      |"
echo "|                                                      |"
echo "|                                                      |"
echo "|                                                      |"
echo "|    This installer was brought to you by AllGray!!    |"
echo "+------------------------------------------------------+"
