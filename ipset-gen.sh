#!/bin/bash
LOGFILE=$1
PATTERNS=$2
IPSET=$3


if [ "$#" -ne 3 ]; then
	echo "$(basename "$0") [log file] [pattern file] [ip set name]"
	echo ""
    echo "log file - path to the dnsmasq log file which contains DNS queries"
	echo "pattern file - file where each line is a regex to test the host against"
	echo "ip set name - name of the ip set for which matched hosts will be added"
	exit 1
fi

ERR=0
if [ ! -f "$LOGFILE" ]; then
	echo "Cannot find log file '$LOGFILE'"
	ERR=1
fi

if [ ! -f "$PATTERNS" ]; then
	echo "Cannot find pattern file '$PATTERNS'"
	ERR=1
fi

if ! ipset -L $IPSET; then
	echo "No ipset with the name '$IPSET' found"
	ERR=1
fi

if [ "$ERR" -ne "0" ]; then
	echo "Errors found, exiting"
	exit 1
fi

HOST_REGEX="(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])"
IPV4_REGEX="(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
REPLY_REGEX="reply $HOST_REGEX is $IPV4_REGEX"

grep -E "$REPLY_REGEX" $LOGFILE | awk 'BEGIN {
	setname="'"$IPSET"'"
	pattern_count=0
	while (getline < "'"$PATTERNS"'")
	{
		patterns[pattern_count]=$0;
		pattern_count++;
	}
	close("'"$PATTERNS"'");
}
{
	host=$6;
	ip=$8;
	for(i=1; i<pattern_count; i++) {
		if (host ~ patterns[i]) {
			cmd = "ipset add " setname " " ip;
			print cmd;
			break;
		}
	}
}' | bash