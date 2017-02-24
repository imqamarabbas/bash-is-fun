#!/bin/bash

# This script will configure tomcat to restart as a service
# insead of using  startup.sh  and shutdown.sh you can simply
# type service tomcat stop / start / restart make a new file 
# named 'tomcat'  in /etc/init.d/ and give permission to execute

start() {
			echo  "Starting Tomcat!!!"
        cd /opt/tomcat/bin/
		sh startup.sh
}
 
stop() {
			echo "Killing Java Process!!!"
		pkill -9 java 
		echo "Stopping Tomcat!!!"
		sh /opt/tomcat/bin/catalina.sh stop
}
 
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 5
        start
        ;;
    *)
        echo "Usage: tomcat {start|stop|restart}"
        exit 1
esac
exit 0

