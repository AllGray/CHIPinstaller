#!/bin/bash
echo 'Downloading new package link' wget -O /tmp/package.txt 
'http://chipinstaller.damianvila.com/package.txt' echo 'Checking if new 
version is available' cat /tmp/package.txt | head -1 > /tmp/version cat 
/tmp/package.txt | tail -1 > /tmp/link (diff /tmp/version 
~/.CHIPinstaller/.version && echo 'Already up-to-date.') || \
    (echo 'Updating...' && \
    mkdir -p ~/.CHIPinstaller/ && \
    cp /tmp/version ~/.CHIPinstaller/.version &&\
    rm -f /CHIPinstaller.tar.gz && \
    wget -O /tmp/CHIPinstaller.tar.gz -i /tmp/link && \
    cd /home/chip
    sudo tar -zxvf /tmp/CHIPinstaller.tar.gz CHIPinstaller
    echo 'Installation finished.')
