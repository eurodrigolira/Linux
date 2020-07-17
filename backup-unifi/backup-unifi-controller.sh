#!/bin/bash
#
# Autor: Rodrigo Lira
# E-mail: eurodrigolira@gmail.com
# Blog: https://rodrigolira.eti.br
#
# Script Original: https://dl.ubnt.com/unifi/5.0.7/unifi_sh_api
#
# VARIÁVEIS
#
DATA=`date +%d-%m-%Y`
USUARIO="USER"
SENHA="PASSWORD"
URL=https://_ENDEREÇO_IP_:8443
BACKUP=/backup/UNIFI-CONTROLLER/
NOME=unifi-controller-$DATA\.unf
CMD="curl -k --cookie /tmp/cookie --cookie-jar /tmp/cookie --insecure --silent --fail"
MAIL_SUCESSO="UNIFI-CONTROLLER - SUCESSO AO REALIZAR BACKUP"
MAIL_FALHA="UNIFI-CONTROLLER - ERRO AO TENTAR REALIZAR BACKUP"
MAIL=ENDEREÇO_DE_E-MAIL
LOG=unifi-controller-$DATA\.log
#
# VERIFICA SE O DIRETÓRIO DE BACKUP EXISTE
if [ ! -d "$BACKUP" ]; then
  echo "[+] DIRETÓRIO JÁ EXISTE" > $BACKUP$LOG
else
  mkdir -p $BACKUP && echo "[+] DIRETÓRIO CRIADO COM SUCESSO" > $BACKUP$LOG
fi
#
# FAZ LOGIN NO UNIFI CONTROLLER
if [ $? == 0 ]; then
  $CMD --data '{"username":"'$USUARIO'","password":"'$SENHA'"}' $URL/api/login > /dev/null && echo "[+] LOGIN REALIZADO COM SUCESSO" >> $BACKUP$LOG
else
  echo "[-] ERRO AO TENTAR FAZER LOGIN NO UNIFI CONTROLLER" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
  exit 0
fi
#
# LOCALIZA O CAMINHO PARA O ARQUIVO DE BACKUP
if [ $? == 0 ]; then
  ARQUIVO=`$CMD --data 'json={"cmd":"backup","days":"-1"}' $URL/api/s/default/cmd/system | sed -n 's/.*\(\/dl.*unf\).*/\1/p'` && echo "[+] ARQUIVO LOCALIZADO COM SUCESSO"
>> $BACKUP$LOG
else
  echo "[-] ERRO AO TENTAR LOCALIZAR O ARQUIVO PARA BACKUP" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
  exit 0
fi
#
# FAZ O DOWNLOAD DO BACKUP
if [ $? == 0 ]; then
  $CMD $URL$ARQUIVO -o $BACKUP/$NOME && echo "[+] DOWNLOAD DO ARQUIVO DE BACKUP REALIZADO COM SUCESSO" >> $BACKUP$LOG
else
  echo "[-] ERRO AO TENTAR FAZER DOWNLOAD DO ARQUIVO DE BACKUP" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
  exit 0
fi
#
# FAZ LOGOUT DO UNIFI CONTROLLER
if [ $? == 0 ]; then
  $CMD $URL/logout && echo "[+] LOGOUT REALIZADO COM SUCESSO" >> $BACKUP$LOG
else
  echo "[-] ERRO AO TENTAR FAZER LOGOUT" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
  exit 0
fi
#
# PROCURA E APAGA ARQUIVOS COM MAIS DE 7 DIAS
if [ $? == 0 ]; then
 find $BACKUP -ctime +7 -name "*.unf" -exec rm -f {} \; && echo "[+] ARQUIVOS COM MAIS DE 7 DIAS REMOVIDOS COM SUCESSO" >> $BACKUP$LOG
else
 echo "[-] ERRO AO TENTAR APAGAR OS ARQUIVOS COM MAIS DE 7 DIAS" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
 exit 0
fi
#
# ENVIA UM E-MAIL
if [ $? == 0 ]; then
 echo "[+] BACKUP REALIZADO COM SUCESSO" >> $BACKUP$LOG && mail -s $MAIL_SUCESSO $MAIL < $BACKUP$LOG
else
 echo "[-] ERRO AO TENTAR REALIZAR O BACKUP" >> $BACKUP$LOG ; mail -s $MAIL_FALHA $MAIL < $BACKUP$LOG
 exit 0
fi
# APAGA O ARQUIVO DE LOG
sleep 10
rm -f $BACKUP$LOG
