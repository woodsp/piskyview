#!/bin/bash

yes | apt-get install python-picamera gpsd gpsd-clients python-gps emacs
crontab -l | { cat; echo "@reboot /usr/bin/python /home/pi/pyskyview/test_camera.py > /home/pi/pyskyview/log 2>&1"; } | crontab -
crontab -l | { cat; echo "*/1 * * * * /home/pi/pyskyview/shoutout.sh > /home/pi/pyskyview/shoutoutlog 2>&1"; } | crontab -
cp config_files/gpsd /etc/default
cp config_files/ntp.conf /etc/
