LOGFILE=$1
PATTERNS=$2
IPSET=$3

HOST_REGEX="(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])"
IPV4_REGEX="(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
REPLY_REGEX="reply $HOST_REGEX is $IPV4_REGEX"

grep -E "$REPLY_REGEX" $LOGFILE | awk '{
	host=$6
	ip=$8
	print host, ip
}'