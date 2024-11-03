#!/bin/bash

#####################################################################
#                                                                   #
# Bate o ponto em https://www.dimepkairos.com.br.                   #
# O usuário e senha podem ser passados como parâmetros ou definidos #
# nas variáveis abaixo de forma estática.                           #
#                                                                   #
#####################################################################

KAIROS_USER='EMAIL'
KAIROS_PASS='SENHA NO KAIROS'
KAIROS_DATE=$(date +"%d-%m-%Y %H:%M:00 - %A - OK")

function usage() {
        echo -e 'Usage:\nkairos.sh -u <email> -p <password>' 1>&2
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

curl -sL --cookie-jar cookie 'https://www.dimepkairos.com.br/Dimep/Account/Marcacao'
curl -sL --cookie-jar cookie -d "UserName=$KAIROS_USER" -d "Password=$KAIROS_PASS" -d "DateMarking=$KAIROS_DATE" 'https://www.dimepkairos.com.br/Dimep/Account/Marcacao'
rm -f cookie
echo "$KAIROS_DATE" >> $HOME/mylogs/kairos.log
