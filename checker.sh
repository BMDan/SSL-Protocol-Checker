#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <hostname> [<port>]" >&2
  echo "  <port> defaults to 443 if not given." >&2
  exit 1
fi

# Could construct this automatically, but we can't trust openssl's -help output
# to stay consistent (and it shouldn't!).  But it would look something like:
#   openssl s_client -help 2>&1 | awk '/[jJ]ust use/ && !/dtls/ {print substr($1,2)}'
TLS_VERSIONS_WITH_CIPHER=(ssl2 ssl3 tls1 tls1_1 tls1_2)
TLS_VERSIONS_WITH_CIPHERSUITES=(tls1_3)

# Remove old TLS versions not supported by the local copy of `openssl`
for (( i=${#TLS_VERSIONS_WITH_CIPHER[@]}-1; i>=0; i-- )); do
  if ! grep -qxF -- "-${TLS_VERSIONS_WITH_CIPHER[$i]}" <(openssl s_client -help 2>&1 | awk '{print $1}'); then
    unset "TLS_VERSIONS_WITH_CIPHER[$i]"
  fi
done

# Create an inverted lookup array out of TLS_VERSIONS_WITH_CIPHERSUITES
declare -a TLS_VERSIONS_WITHOUT_CIPHERS
for tlsv in "${TLS_VERSIONS_WITH_CIPHERSUITES[@]}"; do
  TLS_VERSIONS_WITHOUT_CIPHERS[$tlsv]=1
done

# Find the max length of any cipher{,suite} name
MAX_NAME_LEN=$(openssl ciphers ALL:COMPLEMENTOFALL | tr ':' '\n' | wc -L)

printf "%*s" $((MAX_NAME_LEN - 2)) ""
for tlsv in "${TLS_VERSIONS_WITH_CIPHER[@]}" "${TLS_VERSIONS_WITH_CIPHERSUITES[@]}"; do
  printf "%10s" "$tlsv"
done
echo
for cipher in $(openssl ciphers 'ALL:COMPLEMENTOFALL' | sed 's/:/ /g'); do
#for cipher in $(openssl ciphers 'RSA-PSK-AES256-GCM-SHA384' | sed 's/:/ /g'); do
  tput sc
  found=0
  printf "%*s" "$MAX_NAME_LEN" "$cipher"
  if ! openssl ciphers "$cipher" >/dev/null 2>/dev/null; then
    # We have a "ciphersuite" instead of the usual openssl cipher.  Ciphersuites
    # only work in TLS versions 1.3 and above; conversely, trying to specify a
    # normal cipher in TLSv1.3 mode will just be silently ignored.
    cipherarg=("-ciphersuites" "$cipher")
    APPLICABLE_TLS_VERSIONS=("${TLS_VERSIONS_WITH_CIPHERSUITES[@]}")
    for (( i=0; i<${#TLS_VERSIONS_WITH_CIPHER[@]}; i++ )); do
      printf "%10s" ""
    done
  else
    cipherarg=("-cipher" "$cipher")
    APPLICABLE_TLS_VERSIONS=("${TLS_VERSIONS_WITH_CIPHER[@]}")
  fi
  for tlsv in "${APPLICABLE_TLS_VERSIONS[@]}"; do
    if [ "${TLS_VERSIONS_WITHOUT_CIPHERS+0}" = 1 ]; then
      rv=-1
    else
      openssl s_client -"$tlsv" "${cipherarg[@]}" -connect "${1}:${2:-443}" >>/dev/null 2>&1 </dev/null
      rv=$?
    fi
    printf "%5s%1s%4s" "" "$([ $rv -eq 0 ] && echo "√" || :)" ""
    [ $rv -eq 0 ] && found=1
  done
  if [ $found -eq 0 ]
    then tput rc
    else echo
  fi
done
printf "%78s" " "
tput rc
