#!/bin/sh

NODE_BIN=/opt/nodejs/node
APP_JS=/opt/restify/server.js


_stop( ) {
    ps -ef |grep -v grep |grep 'server.js' |awk '{print $2}' |xargs kill
}

_start( ) {
    # no logging
    #nohup $NODE_BIN $APP_JS > /dev/null &

    # nohup default logging
    nohup $NODE_BIN $APP_JS &
}

_restart( ) {
    _stop
    sleep 0.5
    _start
}

_show_usage( ) {
    echo "Usage: ${0} {start|stop|restart}"
    exit 1
}
case ${1} in
    start|stop|restart)
        [ -x ${NODE_BIN} ] || exit 2
        [ -f ${APP_JS} ] || exit 2
        _${1}
        ;;
    *)
        _show_usage
        ;;
esac
