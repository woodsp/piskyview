#!/bin/bash

apt-get update
apt-get upgrade
apt-get install python-picamera gpsd gpsd-clients python-gps emacs ntpd
crontab -l | { cat; echo "@reboot /usr/bin/python /home/pi/pyskyview/test_camera.py > /home/pi/pyskyview/log 2>&1"; } | crontab -

cp config_files/gpsd /etc/default
cp config_files/keyboard /default/keyboard
cp config_files/ntp.conf /etc/
