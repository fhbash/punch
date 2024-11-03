#!/bin/sh

KAIROS_USER=''
KAIROS_PASS=''
KAIROS_DATE="$(date +"%d-%m-%Y %H:%M:00" | tr ' ' '+' | sed -e 's/:/%3A/g')"
LOGDIR="${HOME}/mylogs"
LOGFILE="${LOGDIR}/kairos.log"

USER_AGENT='Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0'

URL=https://www.dimepkairos.com.br/Dimep/Account/Marcacao
COOKIE=kairos.cookie


usage() {
  printf 'Usage: %s -u <email> -p <password>\n' "${0}" >&2
  exit 1
}

while getopts ":h:u:p:" o; do
  case "${o}" in
  u)
    KAIROS_USER=${OPTARG}
    ;;
  p)
    KAIROS_PASS=${OPTARG}
    ;;
  *)
    usage
    ;;
  esac
done

if [ -z "$KAIROS_USER" ] || [ -z "$KAIROS_PASS" ]; then
  usage
fi

curl -sL -c "${COOKIE}" -e "${URL}" -A "${USER_AGENT}" "${URL}"

curl -sL -b "${COOKIE}" -e "${URL}" -A "${USER_AGENT}" \
     -d "UserName=${KAIROS_USER}" -d "Password=${KAIROS_PASS}" \
     -d "DateMarking=${KAIROS_DATE}" -d "Ip=false" \
     "${URL}"
rm -f "${COOKIE}"

mkdir -p "${LOGDIR}"
echo "${KAIROS_DATE}" >> "${LOGFILE}"
# vim:set ts=2 sw=2 et:
