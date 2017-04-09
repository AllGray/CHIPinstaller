#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run this installer with sudo"
  exit
fi

# Clear the screen
reset

# Grab the current hostname
read -r hostname_old < /etc/hostname

# Start info (banner spacing works assuming hostname: chip)
echo "+-----------------------------------------------------------+"
echo "|                   CHOOSE A NEW HOSTNAME                   |"
echo "|                   Your Hostname is $hostname_old                   |"
echo "| If you want to keep $hostname_old as  your hostname just type $hostname_old |"
echo "|  Be avare that using chip as hostname can cause problems  |"
echo "|   if you have more than 1 CHIP connected to you network   |"
echo "+-----------------------------------------------------------+"

# Choose a new host name
read -p "Choose your new host name: " hostname_new

# Setup OwnCloud Files
wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key
apt-key add - < Release.key

# Add the OwnCloud repository
sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' > /etc/apt/sources.list.d/owncloud.list"
apt-get update

# Install Locals
apt-get -y install locales && dpkg-reconfigure locales && locale-gen

# Install Features
apt-get -y install ntfs-3g owncloud mysql-server-

# If Apt-Get fails to run completely the rest of this isn't going to work...
if [ $? -ne 0 ]
then
    echo "Make sure to run: sudo apt-get update && sudo apt-get upgrade before you run this installer"
    exit
fi

# Make Changes to the PHP 
sed -ie 's/^memory_limit =.*$/memory_limit = 256M/g' /etc/php5/apache2/php.ini
sed -ie 's/^upload_max_filesize =.*$/upload_max_filesize = 2000M/g' /etc/php5/apache2/php.ini
sed -ie 's/^post_max_size =.*$/post_max_size = 2000M/g' /etc/php5/apache2/php.ini
sed -ie 's/^max_execution_time =.*$/max_execution_time = 300/g' /etc/php5/apache2/php.ini

# Set up AVAHI
echo "Setting up avahi"
echo "<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\">" > /etc/avahi/services/afpd.service
echo "<service-group>" >> /etc/avahi/services/afpd.service
echo "<name replace-wildcards=\"yes\">%h</name>" >> /etc/avahi/services/afpd.service
echo "<service>" >> /etc/avahi/services/afpd.service
echo "<type>_afpovertcp._tcp</type>" >> /etc/avahi/services/afpd.service
echo "<port>548</port>" >> /etc/avahi/services/afpd.service
echo "</service>" >> /etc/avahi/services/afpd.service
echo "</service-group>" >> /etc/avahi/services/afpd.service

# Setup host name
read -r hostname_old < /etc/hostname
sed -i "s/$hostname_old/$hostname_new/g" /etc/hostname
sed -i "s/$hostname_old/$hostname_new/g" /etc/hosts
hostname $hostname_new

# Restart AVAHI
sudo /etc/init.d/avahi-daemon restart

# Create directory for mounting external drives to
mkdir /media/ownclouddrive

# Create and add the www-data user to the www-data group
usermod -a -G www-data www-data

# Make the user www-data owner of the mounted drive and make its permissions read, write and execute
chmod -R 775 /media/ownclouddrive
chown -R www-data:www-data /media/ownclouddrive

# Grab Local IP address
hostname -I > local_ip.txt
read -r local_ip < local_ip.txt

# cleanup
rm -r Release.key owncloud-chip-installer.sh local_ip.txt

# Restart Apache
systemctl restart apache2

# Create readme.txt in /user/chip/
cat >/user/chip/owncloud_README.txt <<EOL
"+---------------------------------------------------------------------+"
"|                           Congratulation!                           |"
"|                        Your install is done!                        |"
"|                      Your HOSTNAME is $hostname_new                      |"
"|            If you don't have Bonjour/Netatalk installed,            |"
"|             Head over  to http://$local_ip/owncloud             |"
"|                                                                     |"
"|              if you DO have Bonjour/Netatalk installed              |"
"|             Head over to http://$hostname_new.local/owncloud             |"
"|                        To finish your setup!                        |"
"|                                                                     |"
"| Username:       Pick your Poison                                    |"
"| Password:       Something that is not password123                   |"
"| Data folder:    /media/ownclouddrive/                               |"
"|                                                                     |"
"|            This installer was brought to you by AllGray!            |"
"+---------------------------------------------------------------------+"

EOL

# Clear screen
reset

# Finishing up (banner spacing works assuming hostname: owncloud)
echo "+---------------------------------------------------------------------+"
echo "|                           Congratulation!                           |"
echo "|                        Your install is done!                        |"
echo "|                      Your HOSTNAME is $hostname_new                      |"
echo "|            If you don't have Bonjour/Netatalk installed,            |"
echo "|             Head over  to http://$local_ip/owncloud             |"
echo "|                                                                     |"
echo "|              if you DO have Bonjour/Netatalk installed              |"
echo "|             Head over to http://$hostname_new.local/owncloud             |"
echo "|                        To finish your setup!                        |"
echo "|                                                                     |"
echo "| Username:       Pick your Poison                                    |"
echo "| Password:       Something that is not password123                   |"
echo "| Data folder:    /media/ownclouddrive/                               |"
echo "|                                                                     |"
echo "|            This installer was brought to you by AllGray!            |"
echo "+---------------------------------------------------------------------+"
