#!/bin/sh

set -e

VERSION="0.6.0"
CONF="${RP_CONF:-}"
KAIROS_USER="${KAIROS_USER:-}"
KAIROS_PASS="${KAIROS_PASS:-}"
KAIROS_DATE="$(date +"%d-%m-%Y %H:%M:00")"
CURRENT_DATE="$(date +"%Y-%m-%d-%H.%M.%S")"
LOGDIR="${HOME}/mylogs"
COMPDIR="${HOME}/mylogs/comprovantes"
LOGFILE="${LOGDIR}/kairos.log"
TGLOGFILE="${LOGDIR}/telegram.log"
DEBUG_LOG="${LOGDIR}/${CURRENT_DATE}"
COMPROVANTE="${COMPDIR}/comprovante-${CURRENT_DATE}.pdf"

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
TELEGRAM_BOT_TOKEN="${TG_TOKEN:-}"
TELEGRAM_USER_ID="${TG_ID:-}"

# Paperless Settings
PAPERLESS_URL="${PP_URL:-}/api/documents/post_document/"
PAPERLESS_TOKEN="${PP_TOKEN:-}"
PAPERLESS_TAGS="${PP_TAGS:-ponto}"
PAPERLESS_CORRESPONDENT="${PP_CORRESPONDENT:-punch}"

usage() {
  printf "Usage:
    -u  Kairos email
    -p  Kairos Password
    -v  Versao do script
    -c  Arquivo de Configuracao
    \n\rExample:
     "${0}" -u <email> -p <password>\n"
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
  curl -sL "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage?chat_id=${TELEGRAM_USER_ID}" \
       --form-string "text=${msg}" \
       -F "parse_mode=markdown" -w "\n" >> "${TGLOGFILE}" 2>&1 
}

tg_send_pdf() {
  has_tg_setup || return 0

  pdf_path="${1}"
  caption="${2}"
  curl -sL "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument?chat_id=${TELEGRAM_USER_ID}" \
       -F "document=@${pdf_path}" \
       --form-string "caption=${caption}" -w "\n" >> "${TGLOGFILE}" 2>&1
}

die() {
  echo "## ERRO: ${1}" >&2
  tg_send_message "## ERRO: ${1}"
  exit 1
}

get_cookie() {
  curl -sL -c "${COOKIE}" -e "${URL}" -A "${USER_AGENT}" "${URL}" \
    -o "${DEBUG_LOG}"-01.stdout 2> "${DEBUG_LOG}"-01.stderr || \
    die "Falha ao baixar o cookie"
  [ -s  "${DEBUG_LOG}"-01.stderr ] || rm -f "${DEBUG_LOG}"-01.stderr
}

has_pp_setup() {
  [ -n "${PAPERLESS_URL}" ] || return 1
  [ -n "${PAPERLESS_TOKEN}" ] || return 1
  return 0
}

pp_send(){
  has_pp_setup || return 0

  printf "Enviando comprovante para Paperless-ngx...\n"
  curl -s -X POST "${PAPERLESS_URL}" \
      -H "Authorization: Token ${PAPERLESS_TOKEN}" \
      -F "file=@${COMPROVANTE}" \
      -F "tags=${PAPERLESS_TAGS}" \
      -F "correspondent=${PAPERLESS_CORRESPONDENT}" \
      -o "${DEBUG_LOG}"-03.stdout 2> "${DEBUG_LOG}"-03.stderr || \
      die "Erro ao enviar o comprovante para Paperless-ngx"
}

punch_clock() {
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
    && die "Usuário e/ou senha estão incorretos" || \
    grep -q 'Usuário não encontrado' "${DEBUG_LOG}"-02.stdout && die "Senha Incorreta" ||:
}

punch_save() {
  printf 'Salvando Comprovante: %s\n' "${COMPROVANTE}"
  #punch_result="${LOGDIR}/2024-11-01-17.27.45-02.stdout" # valid result file
  punch_result="${DEBUG_LOG}-02.stdout"
  pdf_bill="$(grep -E 'href="https://storage.*dimepbr-comprovanteponto.*pdf.' \
    "${punch_result}" 2> "${DEBUG_LOG}"-03.stdout | awk -F'[><]' \
    '{print $3}'|head -1)"

  curl -so "${COMPROVANTE}" "${pdf_bill}" || die "Falha ao salvar comprovante"
  [ -s  "${DEBUG_LOG}"-03.stderr ] || rm -f "${DEBUG_LOG}"-03.stderr
  tg_send_pdf "${COMPROVANTE}" "Comprovante ${KAIROS_DATE}"
  
  echo "[$(date)] ${KAIROS_DATE}" >> "${LOGFILE}"
  tg_send_message "Ponto registrado com sucesso - ${KAIROS_DATE}"
  pp_send
}

version() {
  echo "Versao:${VERSION}"
}

main() {
  while getopts ":h:c:u:p:v:" o; do
    case "${o}" in
    u)
      KAIROS_USER="${OPTARG}"
      ;;
    p)
      KAIROS_PASS="${OPTARG}"
      ;;
    c)
      CONF="${OPTARG}"
      ;;
    v)
      version
      ;;
    *)
      usage
      ;;
    esac
  done

  if [ "$1" = "-v" ]; then 
    exit 0
  fi

  if [ -z "$KAIROS_USER" ] || [ -z "$KAIROS_PASS" ] && [ -z "$CONF" ] ; then
    usage
  fi

  if [ -n  "${CONF}" ] ; then
    file="$(realpath "${CONF}" 2>/dev/null || die "Arquivo de configuracao nao encontrado")"
    . "${file}"
  fi
  
  mkdir -p "${LOGDIR}" "${COMPDIR}" 
  get_cookie
  punch_clock
  punch_save
}

main "$@"

# vim:set ts=2 sw=2 et:
