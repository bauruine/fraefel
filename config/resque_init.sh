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
RAKE_FILE=$APP_ROOT/Rakefile

CMD="rake -f $RAKE_FILE environment resque:work PIDFILE=$PID BACKGROUND=yes QUEUE=* RAILS_ENV=production"

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}


case "$1" in
    start)
        sig 0 && echo >&2 "Already running" && exit 0
        su -c "$CMD" - tzhbami7
        ;;
    stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
    restart)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting '$CMD' instead"
        su -c "$CMD" - tzhbami7
        ;;
esac

exit 0
