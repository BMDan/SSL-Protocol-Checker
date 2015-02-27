#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <hostname> [<port>]" >&2
  echo "  <port> defaults to 443 if not given." >&2
  exit 1
fi

# Alternatively: TLSV=$(openssl s_client -help 2>&1 | awk '/just use/ && !/dtls/ {print $1}' | sed 's/-//')
TLSV="ssl2 ssl3 tls1 tls1_1 tls1_2"
printf "%28s" ""
for tlsv in $TLSV; do
  printf "%10s" "$tlsv"
done
echo
for cipher in $(openssl ciphers 'ALL:COMPLEMENTOFALL' | sed 's/:/ /g'); do
  tput sc
  found=0
  printf "%30s" "$cipher"
  for tlsv in $TLSV; do
    cat /dev/null | openssl s_client -$tlsv -cipher $cipher -connect $1:${2:-443} >>/dev/null 2>&1
    rv=$?
    printf "     $([ $rv -eq 0 ] && echo "√" || echo " ")    "
    [ $rv -eq 0 ] && found=1
  done
  if [ $found -eq 0 ]
    then tput rc
    else echo
  fi
done
printf "%78s\n" " "
