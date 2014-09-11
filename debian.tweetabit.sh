#! /bin/sh
# /etc/init.d/tweetabit.sh

# Made by TheZero

# . /etc/rc.d/init.d/functions  # uncomment/modify for your killproc

DAEMON=/usr/bin/tweetabit.rb
NAME=tweetabit.rb

test -x $DAEMON || exit 0

case "$1" in
    start)
    echo -n "Starting Tweet-A-Bit: "
    start-stop-daemon --start --exec $DAEMON
    echo "tweet-a-bit."
    ;;
    stop)
    echo -n "Shutting Tweet-A-Bit:"
    start-stop-daemon --stop --oknodo --retry 30 --exec $DAEMON
    echo "tweet-a-bit."
    ;;

    restart)
    echo -n "Restarting Tweet-A-Bit: "
    start-stop-daemon --stop --oknodo --retry 30 --exec $DAEMON
    start-stop-daemon --start --exec $DAEMON
    echo "tweet-a-bit."
    ;;

    *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac
exit 0

