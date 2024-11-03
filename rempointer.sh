#!/bin/sh

set -e

KAIROS_USER="${KAIROS_USER:-}"
KAIROS_PASS="${KAIROS_PASS:-}"
KAIROS_DATE="$(date +"%d-%m-%Y %H:%M:00")"
LOGDIR="${HOME}/mylogs"
COMPDIR="${HOME}/mylogs/comprovantes"
LOGFILE="${LOGDIR}/kairos.log"
DEBUG_LOG="${LOGDIR}/$(date +"%Y-%m-%d-%H.%M.%S")"
COMPROVANTE="${COMPDIR}/comprovante-$(date +"%Y-%m-%d-%H.%M.%S")".pdf

USER_AGENT='Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0'

URL=https://www.dimepkairos.com.br/Dimep/Account/Marcacao
COOKIE="${DEBUG_LOG}".cookie

# Setup for the telegram:
# 1. Talk to #BotFather (in telegram) to create a telegram bot;
# 2. Talk to the bot you just created, so that it is able to
#    communicate with you;
# 3. Still in BotFather, take  note of its API token and put it in the
#    TELEGRAM_BOT_TOKEN variable below;
# 4. Get also your own user ID, and add to the TELEGRAM_USER_ID below. You
#    can get your id by talking to @JsonDumpBot -- you are interested in
#    the "id" field from the "from" object, which is inside "message";
TELEGRAM_BOT_TOKEN=
TELEGRAM_USER_ID=


usage() {
  printf 'Usage: %s -u <email> -p <password>\n' "${0}" >&2
  exit 0
}

has_tg_setup() {
  [ -n "${TELEGRAM_USER_ID}" ] || return 1
  [ -n "${TELEGRAM_BOT_TOKEN}" ] || return 1
  return 0
}

tg_send_message() {
  has_tg_setup || return 0

  msg="${1}"
  curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage?chat_id=${TELEGRAM_USER_ID}" \
       --form-string "text=${msg}" \
       -F "parse_mode=markdown"
}

tg_send_pdf() {
  has_tg_setup || return 0

  pdf_path="${1}"
  caption="${2}"
  curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument?chat_id=${TELEGRAM_USER_ID}" \
       -F "document=@${pdf_path}" \
       --form-string "caption=${caption}"
}

die() {
  echo "## ERRO: ${1}" >&2
  tg_send_message "## ERRO: ${1}"
  exit 1
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

printf 'Batendo Ponto em: %s\n' "${KAIROS_DATE}"
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

printf 'Salvando Comprovante: %s\n' "${COMPROVANTE}"
curl -so "${COMPROVANTE}" \
  "$(grep -E 'href="https://storage.*dimepbr-comprovanteponto.*pdf.' \
  "${DEBUG_LOG}"-02.stdout|awk -F'>' '{print $2}'|awk -F'<' '{print $1}'|head -1)"
tg_send_pdf "${COMPROVANTE}" "Comprovante ${KAIROS_DATE}"

echo "[$(date)] ${KAIROS_DATE}" >> "${LOGFILE}"
tg_send_message "Ponto registrado com successo - ${KAIROS_DATE}"

# vim:set ts=2 sw=2 et:
