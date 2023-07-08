#!/bin/sh
#
#   wwan_check.sh
#
#   Checks internet connection and restarts
#   the modem if internet is lost
#
#   Copyright (C) 2023 Mikhail Zhilkin <csharper2005@gmail.com>
#
# NOTE: Add this script to cron (runs every 5 min in this example):
# */5 * * * * /root/scripts/wwan_check.sh

### Common vars
## IP to check
CHECK_IP="8.8.8.8"
## Your WWAN interface
WWAN_DEV="eth2"
## Retries count
PING_MAX_RETRIES=3
## Modem restart command
MODEM_RESTART_CMD="AT+CFUN=1,1\r"
#MODEM_RESTART_CMD="AT+QPOWD=1\r"
## Modem TTY
#MODEM_TTY="/dev/ttyUSB2"
MODEM_TTY="/dev/ttyACM2"

fails=0
while [ $fails -ne $PING_MAX_RETRIES ]; do
	/bin/ping -I $WWAN_DEV -c 1 $CHECK_IP >/dev/null 2>&1
	[ "$?" -eq 0 ] && break
	fails=$((fails+1))
done

[ $fails -eq $PING_MAX_RETRIES ] && \
	logger "[${0##*/}] Ping lost $PING_MAX_RETRIES times on $WWAN_DEV WWAN interface" && \
	echo -e $MODEM_RESTART_CMD > $MODEM_TTY  && \
	logger "[${0##*/}] Modem on $MODEM_TTY has been restarted"
