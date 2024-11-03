#!/bin/sh

set -e

KAIROS_USER="${KAIROS_USER:-}"
KAIROS_PASS="${KAIROS_PASS:-}"
KAIROS_DATE="$(date +"%d-%m-%Y %H:%M:00")"
LOGDIR="${HOME}/mylogs"
LOGFILE="${LOGDIR}/kairos.log"
DEBUG_LOG="${LOGDIR}/$(date +"%Y-%m-%d-%H.%M.%S")"

USER_AGENT='Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0'

URL=https://www.dimepkairos.com.br/Dimep/Account/Marcacao
COOKIE="${DEBUG_LOG}".cookie

die() {
  echo "## ERRO: ${1}" >&2
  exit 1
}

usage() {
  printf 'Usage: %s -u <email> -p <password>\n' "${0}" >&2
  exit 0
}

while getopts ":h:u:p:" o; do
  case "${o}" in
  u)
    KAIROS_USER="${OPTARG}"
    ;;
  p)
    KAIROS_PASS="${OPTARG}"
    ;;
  *)
    usage
    ;;
  esac
done

if [ -z "$KAIROS_USER" ] || [ -z "$KAIROS_PASS" ]; then
  usage
fi

mkdir -p "${LOGDIR}"

curl -sL -c "${COOKIE}" -e "${URL}" -A "${USER_AGENT}" "${URL}" \
  -o "${DEBUG_LOG}"-01.stdout 2> "${DEBUG_LOG}"-01.stderr
[ -s  "${DEBUG_LOG}"-01.stderr ] || rm -f "${DEBUG_LOG}"-01.stderr


curl -sL -b "${COOKIE}" -e "${URL}" -A "${USER_AGENT}" \
     -d "UserName=${KAIROS_USER}" \
     --data-urlencode "Password=${KAIROS_PASS}" \
     --data-urlencode "DateMarking=${KAIROS_DATE}" \
     -d "Ip=false" \
     "${URL}" \
     -o "${DEBUG_LOG}"-02.stdout 2> "${DEBUG_LOG}"-02.stderr
[ -s  "${DEBUG_LOG}"-02.stderr ] || rm -f "${DEBUG_LOG}"-02.stderr

grep -q 'Usuário e/ou senha estão incorretos' "${DEBUG_LOG}"-02.stdout \
  && die "Usuário e/ou senha estão incorretos"

echo "[$(date)] ${KAIROS_DATE}" >> "${LOGFILE}"
# vim:set ts=2 sw=2 et:
