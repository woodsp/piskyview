#!/bin/bash

yes | apt-get install python-picamera gpsd gpsd-clients python-gps emacs dnsutils
crontab -l | { cat; echo "@reboot /usr/bin/python /home/pi/piskyview/test_camera.py >> /home/pi/piskyview/test_camera.log 2>&1"; } | crontab -
crontab -l | { cat; echo "*/1 * * * * /home/pi/piskyview/shoutout.sh >> /home/pi/piskyview/shoutout.log 2>&1"; } | crontab -
cp config_files/gpsd /etc/default
cp config_files/ntp.conf /etc/

# accept remote key for later ssh connections
ssh-keyscan -H naturalcapitalproject.org >> ~/.ssh/known_hosts

