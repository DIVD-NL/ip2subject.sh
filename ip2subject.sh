#!/bin/bash
if [[ "$1" == "-h" || "$1" == "--help" || -z $1 ]]; then
	echo "$0 [-h|--help] HOST [PORT]"
	echo "This script connects to HOST on PORT (443 by default) and gets the subject from the certificate."
	exit 0
fi

if [[ -z $2 ]]; then
	port=443
else
	port=$2
fi

set +e
gtimeout 1 bash -c "cat < /dev/null > /dev/tcp/$1/443"
if [[ "$?" -eq 0 ]]; then
	set -e
	cert=`echo ""|openssl s_client -showcerts -servername divd.nl -connect $1:443 2>/dev/null`
	parsed=`echo "$cert" | openssl x509 -inform pem -noout -text`
	subject=`echo "$parsed"|grep Subject:|sed 's/^.*CN\=//'|sed 's/\/emailAddress.*//'`
	echo "$1	$subject"
else
	set -e
	echo "$1	*down*"
fi
