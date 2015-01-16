import time
import os
import errno
import sys
import threading

import picamera
import gps

gpsd=None

class GpsPoller(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        global gpsd #bring it in scope
        gpsd = gps.gps(mode=gps.WATCH_ENABLE | gps.WATCH_NEWSTYLE) #starting the stream of info
        self.current_value = None
        self.running = True #setting the thread running to true
 
    def run(self):
        global gpsd
        while gpsp.running:
            gpsd.next() #this will continue to loop and grab EACH set of gpsd info to clear the buffer
        gpsd=None


if __name__ == '__main__':
    print 'starting GPS'
    gpsp = GpsPoller()
    gpsp.start()

    path = '/home/pi/camera/output'

    print 'make output directory'

    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

    print 'starting camera'

    with picamera.PiCamera() as camera:
        camera.resolution = (2592, 1944)
        print 'waiting to power up'
        time.sleep(1)
        camera.exposure_mode = 'sports'

        n_exceptions = 0
        while True:
            #read a GPS location
            try:
                lat_lng_string = "%s,%s" % (gpsd.fix.latitude, gpsd.fix.longitude)
            except AttributeError:
                lat_lng_string = "no gps fix"
            except KeyError:
                lat_lng_string = "no gps fix"
            except StopIteration:
                session = None
                lat_lng_string = "GPSD has terminated"

            #Take a picture
            try:
                timestr = time.strftime("%Y%m%d-%H%M%S")

                if camera.exposure_mode == 'sports':
                    camera.exposure_mode = 'auto'
                else:
                    camera.exposure_mode = 'sports'

                filename = '%s_%s.jpg' % (timestr, camera.exposure_mode)
                camera.capture(os.path.join(path, filename))
                print '%s,%s' % (lat_lng_string, filename)
                sys.stdout.flush()

                #Stop if we have less than 100MB
                st = os.statvfs(path)
                free_meg = st.f_bavail * st.f_frsize / 2**20
                if free_meg < 100:
                    break
                time.sleep(1)
                n_exceptions = 0
            except picamera.exc.PiCameraRuntimeError as exception:
                print 'encountered exception %s' % str(exception)
                n_exceptions += 1
                if n_exceptions > 50:
                    print 'There have been too many exceptions in a row. Exiting'
                    raise
        print 'done'
