echo 'Updating...' 
mkdir -p ~/.CHIPinstaller/ 
cp /tmp/version ~/.CHIPinstaller/.version 
rm -f /CHIPinstaller.tar.gz 
sudo rm -R /home/chip/CHIPinstaller
wget -O /tmp/CHIPinstaller.tar.gz -i /tmp/link && 
cd /home/chip
sudo tar -zxvf /tmp/CHIPinstaller.tar.gz CHIPinstaller
echo "Installation finished."
cd /home/chip/CHIPinstaller
exec ./CHIPinstaller.sh

