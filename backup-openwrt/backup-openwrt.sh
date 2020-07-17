#!/bin/sh
#
# Autor: Rodrigo Lira
# E-mail: eurodrigolira@gmail.com
# Blog: https://rodrigolira.eti.br
#
# Script para backup do OpenWrt
#
# VARIAVEIS
NOME=backup-openwrt
DATA=`date +%d_%m_%Y`
#
# CRIANDO O BACKUP DENTRO DO /tmp
sysupgrade --create-backup /tmp/$NOME-$DATA.tar.gz
#
# ENVIA O ARQUIVO VIA SCP PARA SERVIDOR DE BACKUP
scp -P"PORTA" /tmp/$NOME-$DATA.tar.gz "USUARIO"@"IP-DO-SERVIDOR":/"DESTINO"
#
# APAGA O ARQUIVO DE BACKUP
rm /tmp/$NOME-$DATA.tar.gz
