#!/usr/bin/env bash
# set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
DNS_SERVER=${DNSSERVER}
if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    echo "=============================================================================================="
    exit 1
fi
STATUS="OK"
NAMESERVER_CHECK=$(dig +timeout=1 @ns1.ipv64.net 2> /dev/null)
echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
if [ "${STATUS}" = "FAIL" ] ; then
    echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ns1.ipv64.net ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
    echo "=============================================================================================="
    exit 1
fi

if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @$DNS_SERVER`" >> /var/log/cron.log 2>&1
    done
else
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @$DNS_SERVER`" >> /var/log/cron.log 2>&1
    done
fi
echo "=============================================================================================="
