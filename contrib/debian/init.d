#! /bin/sh

### BEGIN INIT INFO
# Provides:          fusioninventory-agent
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts FusionInventory Agent
# Description:       starts FusionInventory Agent using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/fusioninventory-agent
DAEMON_OPTS=-d
NAME=fusioninventory-agent
DESC=fusioninventory-agent

test -x $DAEMON || exit 0

# Include fusioninventory-_agent defaults if available
if [ -f /etc/default/fusioninventory-agent ] ; then
	. /etc/default/fusioninventory-agent
fi

. /lib/lsb/init-functions


if [ ! "$MODE" = "daemon"  ]; then
   echo "Daemon mode disabled in /etc/default/fusioninventory-agent"
   exit 0
fi


case "$1" in
  start)
	echo -n "Starting $DESC: "
	start-stop-daemon --start --quiet --pidfile /var/run/$NAME.pid \
		--exec $DAEMON -- $DAEMON_OPTS || true
	echo "$NAME."
	;;
  stop)
	echo -n "Stopping $DESC: "
	start-stop-daemon --stop --quiet --pidfile /var/run/$NAME.pid \
		--exec /usr/bin/perl || true
	echo "$NAME."
	;;
  restart|force-reload)
	echo -n "Restarting $DESC: "
	start-stop-daemon --stop --quiet --pidfile \
		/var/run/$NAME.pid --exec $DAEMON || true
	sleep 1
	start-stop-daemon --start --quiet --pidfile \
		/var/run/$NAME.pid --exec $DAEMON -- $DAEMON_OPTS || true
	echo "$NAME."
	;;
  status)
	status_of_proc -p /var/run/$NAME.pid "$DAEMON" fusioninventory-agent && exit 0 || exit $?
	;;
  *)
	echo "Usage: $NAME {start|stop|restart|status}" >&2
	exit 1
	;;
esac

exit 0
