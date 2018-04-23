#!/bin/bash

sudo cp /usr/share/postfix/main.cf.dist /etc/postfix/main.cf

sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "relayhost = [smtp.gmail.com]:587" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_tls_CApath = /etc/pki/tls/certs/ca-bundle.crt" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_tls_security_options = noanonymous" >> /etc/postfix/main.cf
sudo echo -e "\n" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_mechanism_filter = plain" >> /etc/postfix/main.cf

sudo echo "[smtp.gmail.com]:587 xxx@gmail.com:password" > /etc/postfix/sasl_passwd
