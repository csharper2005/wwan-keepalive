#!/bin/sh
#
#   mf_ipv6_check.sh
#
#   Checks for the global IPv6 address on WWAN interface
#   and restarts the modem if it doesn't exist
#
#   Copyright (C) 2023 Mikhail Zhilkin <csharper2005@gmail.com>
#
# HOWTO:
# 1. Copy mf_ipv6_check.sh to /root/scripts
# 2. Make the script executable:
#    chmod a+x /root/scripts/mf_ipv6_check.sh
# 3. Edit common vars if it's necessary
# 4. Add this line to the cron (to run every 5 min):
#    */5 * * * * /root/scripts/mf_ipv6_check.sh

### Common vars
## WWAN interface
WWAN_DEV="eth2"
## Modem restart command
MODEM_RESTART_CMD="AT+CFUN=1,1\r"
#MODEM_RESTART_CMD="AT+QPOWD=1\r"
## Modem TTY
#MODEM_TTY="/dev/ttyUSB2"
MODEM_TTY="/dev/ttyACM2"

ipv4=$(ip -4 addr show dev $WWAN_DEV | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
[ -z "$ipv4" ] && exit 0

ipv6=$(ip -6 addr show dev $WWAN_DEV scope global | \
	sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')
[ -z "$ipv6" ] && \
	logger "[${0##*/}] No global IPv6 address on $WWAN_DEV WWAN interface" && \
	echo -e $MODEM_RESTART_CMD > $MODEM_TTY  && \
	logger "[${0##*/}] Modem on $MODEM_TTY has been restarted"
