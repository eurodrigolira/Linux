#!/bin/bash
#
# Autor: Rodrigo Lira
# E-mail: eurodrigolira@gmail.com
# Blog: https://rodrigolira.eti.br
#
# Script para configuracao de relay smtp para o gmail no CentOS 7 / Red Hat 7 / Oracle Linux 7
#
# ENTRADA DOS DADOS DE EMAIL E SENHA
echo "Digite o endereco de e-mail:"
read email
echo " "
echo "Digite a senha do email:"
read senha
#
# INSTALACAO DAS DEPENDENCIAS
yum install postfix mailx cyrus-sasl cyrus-sasl-plain -y
#
# CONFIGURACAO DE USUARIO E SENHA
echo "[smtp.gmail.com]:587 $email:$senha" > /etc/postfix/sasl_passwd
#
# CONFIGURACAO DA PERMISSAO DO ARQUIVO
chmod 600 /etc/postfix/sasl_passwd
#
# CONFIGURACOES NO main.cf
echo "relayhost = [smtp.gmail.com]:587" >> /etc/postfix/main.cf
echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
echo "smtp_sasl_security_options =" >> /etc/postfix/main.cf
echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
echo "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt" >> /etc/postfix/main.cf
#
# COMPILA O HASH DA SENHA
postmap /etc/postfix/sasl_passwd
#
# HABILITA O SERVIÇO DO POSTFIX
systemctl enable postfix
#
# INICIA/REINICIA O SERVIÇO DO POSTFIX
systemctl restart postfix
#
# FIM
