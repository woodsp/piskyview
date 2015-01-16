## try and connect to the outside world
## by looking for a network connection and attempting a reverse ssh
## that would allow us to ssh to the raspberry without needing to know its IP


## check for network connection
cable=$(grep "" /sys/class/net/eth0/carrier)
if [ $cable -eq 1 ]
then
  ## then create reverse SSH
  ssh -R 12000:localhost:22 piroot@naturalcapitalproject.org
fi

