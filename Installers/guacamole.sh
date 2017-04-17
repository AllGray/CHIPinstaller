#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Grab hostname
read -r hostname_old < /etc/hostname

# Clear the screen
reset

# Install dialog depend
apt-get -y install dialog

# Make temp dir
mkdir /home/chip/temp

# Display the dialog box
dialog --inputbox "Choose your new HOSTNAME:" 8 40 2>/home/chip/temp/hostname_new

# Setup Hostname
read -r hostname_new < /home/chip/temp/hostname_new
read -r hostname_old < /etc/hostname
sed -i "s/$hostname_old/$hostname_new/g" /etc/hostname
sed -i "s/$hostname_old/$hostname_new/g" /etc/hosts

# Setup MySQL
dialog --inputbox "Enter the password that will be used for MySQL Root:" 8 40 2>/home/chip/temp/mysqlrootpassword
read -r mysqlrootpassword < /home/chip/temp/mysqlrootpassword

# setup for MySQL Root
debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysqlrootpassword"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysqlrootpassword"

# Grab a password for Guacamole Database User Account
dialog --inputbox "Enter the password that will be used for Guacamole Database:" 8 40 2>/home/chip/temp/guacdbuserpassword
read -r guacdbuserpassword < /home/chip/temp/guacdbuserpassword

# Install Features
apt-get update
apt-get -y install build-essential libcairo2-dev libjpeg62-turbo-dev libpng12-dev libossp-uuid-dev libavcodec-dev libavutil-dev \
libswscale-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev mysql-server mysql-client mysql-common mysql-utilities tomcat8 freerdp ghostscript jq

VERSION="0.9.11"
SERVER=$(curl -s 'https://www.apache.org/dyn/closer.cgi?as_json=1' | jq --raw-output '.preferred|rtrimstr("/")')

# If Apt-Get fails to run completely the rest of this isn't going to work...
if [ $? != 0 ]
then
    echo "Make sure to run: sudo apt-get update && sudo apt-get upgrade"
    exit
fi

# Add GUACAMOLE_HOME to Tomcat8 ENV
echo "" >> /etc/default/tomcat8
echo "# GUACAMOLE EVN VARIABLE" >> /etc/default/tomcat8
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat8

# Download Guacample Files
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/source/guacamole-server-${VERSION}-incubating.tar.gz
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/binary/guacamole-${VERSION}-incubating.war
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/binary/guacamole-auth-jdbc-${VERSION}-incubating.tar.gz
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.41.tar.gz

# Extract Guacamole Files
tar -xzf guacamole-server-${VERSION}-incubating.tar.gz
tar -xzf guacamole-auth-jdbc-${VERSION}-incubating.tar.gz
tar -xzf mysql-connector-java-5.1.41.tar.gz

# MAKE DIRECTORIES
mkdir /etc/guacamole
mkdir /etc/guacamole/lib
mkdir /etc/guacamole/extensions

# Install GUACD
cd guacamole-server-${VERSION}-incubating
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl enable guacd
cd ..

# Move files to correct locations
mv guacamole-${VERSION}-incubating.war /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat8/webapps/.
cp mysql-connector-java-5.1.41/mysql-connector-java-5.1.41-bin.jar /etc/guacamole/lib/
cp guacamole-auth-jdbc-${VERSION}-incubating/mysql/guacamole-auth-jdbc-mysql-${VERSION}-incubating.jar /etc/guacamole/extensions/

# Configure guacamole.properties
echo "mysql-hostname: localhost" >> /etc/guacamole/guacamole.properties
echo "mysql-port: 3306" >> /etc/guacamole/guacamole.properties
echo "mysql-database: guacamole_db" >> /etc/guacamole/guacamole.properties
echo "mysql-username: guacamole_user" >> /etc/guacamole/guacamole.properties
echo "mysql-password: $guacdbuserpassword" >> /etc/guacamole/guacamole.properties
rm -rf /usr/share/tomcat8/.guacamole
ln -s /etc/guacamole /usr/share/tomcat8/.guacamole

# restart tomcat
service tomcat8 restart

# Create guacamole_db and grant guacamole_user permissions to it

# SQL Code
SQLCODE="
create database guacamole_db;
create user 'guacamole_user'@'localhost' identified by \"$guacdbuserpassword\";
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'localhost';
flush privileges;"

# Execute SQL Code
echo $SQLCODE | mysql -u root -p$mysqlrootpassword

# Add Guacamole Schema to newly created database
cat guacamole-auth-jdbc-${VERSION}-incubating/mysql/schema/*.sql | mysql -u root -p$mysqlrootpassword guacamole_db

# Grab Local IP address
hostname -I > local_ip.txt
read -r local_ip < local_ip.txt

# Cleanup
rm -rf guacamole-*
rm -rf mysql-connector-java-5.1.41*
rm -rf temp

# Create Readme.txt in /home/chip
cat >/home/chip/guacamole_README.txt <<EOL
"+---------------------------------------------------------------------+"
"|                           Congratulation!                           |"
"|                        Your install is done!                        |"
"|                   Your HOSTNAME is $hostname_new                    |"
"|            If you don't have Bonjour/Netatalk installed,            |"
"|           Head over to http://$local_ip:8080/guacamole           |"
"|                                                                     |"
"|              if you DO have Bonjour/Netatalk installed              |"
"|        Head over to http://$hostname_new.local:8080/guacamole        |"
"|                        To finish your setup!                        |"
"|                                                                     |"
"| Username:     guacadmin                                             |"
"| Password:     guacadmin                                             |"
"|                                                                     |"
"|    After you log in for the first time, create a new admin user!    |"
"|       Log in as your new admin user and remove guacadmin user       |"
"|            This installer was brought to you by AllGray!            |"
"|               And the rest of the CHIPinstaller team                |"
"+---------------------------------------------------------------------+"
EOL


# Clear screen
reset

# Finishing up
echo "+---------------------------------------------------------------------+"
echo "|                           Congratulation!                           |"
echo "|                        Your install is done!                        |"
echo "|                   Your HOSTNAME is $hostname_new                    |"
echo "|            If you don't have Bonjour/Netatalk installed,            |"
echo "|           Head over to http://$local_ip:8080/guacamole           |"
echo "|                                                                     |"
echo "|              if you DO have Bonjour/Netatalk installed              |"
echo "|        Head over to http://$hostname_new.local:8080/guacamole        |"
echo "|                        To finish your setup!                        |"
echo "|                                                                     |"
echo "| Username:     guacadmin                                             |"
echo "| Password:     guacadmin                                             |"
echo "|                                                                     |"
echo "|    After you log in for the first time, create a new admin user!    |"
echo "|       Log in as your new admin user and remove guacadmin user       |"
echo "|            This installer was brought to you by AllGray!            |"
echo "|               And the rest of the CHIPinstaller team                |"
echo "+---------------------------------------------------------------------+"
