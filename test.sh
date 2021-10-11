#!/usr/bin/env bash

/usr/bin/sabnzbdplus -b 0 -f /config/config.ini -s 0.0.0.0:8080 --disable-file-log &

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get install -qqy curl

MAX=10
i=0

until [ $i -ge $MAX ]
do
  HTTP_CODE=$(curl -sL -w "%{http_code}\\n" "http://127.0.0.1:8080/" -o /dev/null)
  [ $? -eq 0 ] && break
  i=$((i+1))
  sleep 5
done

[ "$HTTP_CODE" != "200" ] && >&2 echo "SABnzbd HTTP Code: $HTTP_CODE" && exit 1

exit 0
