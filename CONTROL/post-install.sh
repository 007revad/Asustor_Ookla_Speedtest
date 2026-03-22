#!/bin/sh

case "$1" in
    install)
        echo "Starting $NAME"
		ldconfig
        ;;
    upgrade)
        echo "Stopping $NAME"
        ;;
    *)
        ;;
esac

exit 0
