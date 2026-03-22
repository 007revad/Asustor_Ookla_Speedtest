#!/bin/sh
NAME="Asustor Ookla Speedtest"
PKG_DIR="/usr/local/AppCentral/Asustorspeedtest"
PIDFILE="${PKG_DIR}/var/httpd.pid"

case "$1" in
    start)
        echo "Starting $NAME"
        # BusyBox httpd with CGI support
        busybox httpd -p 39876 -h "${PKG_DIR}/webman" \
            -c "${PKG_DIR}/var/httpd.conf" \
            -f &
        echo $! > "$PIDFILE"
        ;;
    stop)
        echo "Stopping $NAME"
        if [ -f "$PIDFILE" ]; then
            kill $(cat "$PIDFILE") 2>/dev/null
            rm -f "$PIDFILE"
        fi
        ;;
    restart|force-reload)
        $0 stop
        sleep 1
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 2
        ;;
esac
exit 0
