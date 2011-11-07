#! /bin/sh
### BEGIN INIT INFO
# Provides:          Was macht das Skript?
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Kurze Beschreibung
# Description:       Längere Bechreibung
### END INIT INFO
# Author: Name <michael.balsiger@swisscom.com>

# Aktionen

APP_ROOT=/home/tzhbami7/code/rails/fraefel
PID=$APP_ROOT/tmp/pids/resque.pid
CMD="PIDFILE=$PID BACKGROUND=yes QUEUE=* rake environment resque:work"

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}


case "$1" in
    start)
        sig 0 && echo >&2 "Already running" && exit 0
        cd $APP_ROOT
        su -c "$CMD" - tzhbami7
        ;;
    stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
    restart)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting '$CMD' instead"
        cd $APP_ROOT
        su -c "$CMD" - tzhbami7
        ;;
esac

exit 0
