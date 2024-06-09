#!/bin/bash

# Script: configurar_servidor_email.sh
# Descripción: Instala y configura un servidor de correo electrónico con Dovecot y Postfix

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --user USER --host HOST --full-host FULL_HOST --network NETWORK --ip IP --storage STORAGE"
    echo
    echo "Opciones:"
    echo "  --user USER          - Nombre del usuario"
    echo "  --host HOST          - Nombre del host"
    echo "  --full-host FULL_HOST - Nombre completo del host"
    echo "  --network NETWORK    - Red (ej. 192.168.1.0)"
    echo "  --ip IP              - Dirección IP del servidor"
    echo "  --storage STORAGE    - Límite de almacenamiento (ej. 10G)"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user)
            USER="$2"
            shift
            ;;
        --host)
            HOST="$2"
            shift
            ;;
        --full-host)
            FULL_HOST="$2"
            shift
            ;;
        --network)
            NETWORK="$2"
            shift
            ;;
        --ip)
            IP="$2"
            shift
            ;;
        --storage)
            STORAGE="$2"
            shift
            ;;
        -h|--help)
            mostrar_ayuda
            exit 0
            ;;
        *)
            echo "Opción desconocida: $1"
            mostrar_ayuda
            exit 1
            ;;
    esac
    shift
done

# Comprobar parámetros obligatorios
if [[ -z "$USER" || -z "$HOST" || -z "$FULL_HOST" || -z "$NETWORK" || -z "$IP" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar Dovecot
echo "Instalando Dovecot..."
apt-get update
apt-get install -y dovecot-imapd

# Configurar Dovecot
echo "Configurando Dovecot..."
echo "mail_location = maildir:~/Maildir" > /etc/dovecot/local.conf

# Verificar configuración de Dovecot
echo "Verificando configuración de Dovecot..."
sudo dovecot -n

# Crear directorios de correo
echo "Creando directorios de correo..."
su - $USER -c "maildirmake.dovecot ~/Maildir"
maildirmake.dovecot /etc/skel/Maildir
sudo service dovecot restart

# Prueba con telnet
echo "Prueba con telnet..."
telnet 127.0.0.1 imap <<EOF
a login $USER $USER_PASSWORD
a examine inbox
a logout
EOF

# Modificar 10-mail.conf
echo "Modificando /etc/dovecot/conf.d/10-mail.conf..."
sed -i 's/^#mail_plugins =/mail_plugins = $mail_plugins imap_quota/' /etc/dovecot/conf.d/10-mail.conf

# Modificar local.conf para plugins
echo "Modificando /etc/dovecot/local.conf..."
cat <<EOL >> /etc/dovecot/local.conf

## Plugins
mail_plugins = \$mail_plugins quota
protocol imap {
  mail_plugins = \$mail_plugins imap_quota
}
plugin {
  quota = maildir
  quota_rule = *:storage=$STORAGE
}
## Fin

EOL

# Reiniciar Dovecot
echo "Reiniciando Dovecot..."
sudo systemctl restart dovecot

# Prueba de nuevo con telnet
echo "Prueba de nuevo con telnet..."
telnet 127.0.0.1 imap

# Instalar Postfix
echo "Instalando Postfix..."
apt-get install -y postfix postfix-doc

# Configurar Postfix
echo "Configurando Postfix..."
sed -i "s/^mydestination =.*/mydestination = $HOST, $FULL_HOST, localhost.$HOST, localhost/" /etc/postfix/main.cf
sed -i "s/^mynetworks =.*/mynetworks = 127.0.0.0\/8, $NETWORK\/24/" /etc/postfix/main.cf
sed -i "s/^inet_interfaces =.*/inet_interfaces = 127.0.0.1, $IP/" /etc/postfix/main.cf

# Agregar configuraciones adicionales a Postfix
cat <<EOL >> /etc/postfix/main.cf

home_mailbox = Maildir/

smtpd_client_restrictions = permit_mynetworks, reject
smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination
smtpd_helo_restrictions = reject_unknown_sender_domain
smtpd_sender_restrictions = reject_unknown_sender_domain

EOL

# Reiniciar Postfix
echo "Reiniciando Postfix..."
sudo service postfix restart

# Prueba con telnet SMTP
echo "Creando un correo con telnet..."
telnet localhost smtp <<EOF
EHLO localhost
MAIL FROM: $USER@$HOST
RCPT TO: $USER@$HOST
DATA
Subject: Sujeto
Mensaje
.
quit
EOF

# Configurar autenticación
echo "Configurando autenticación en Dovecot..."
cat <<EOL >> /etc/dovecot/local.conf

## Autentificación
auth_mechanisms = plain login
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
  }
}
## Fin

EOL

# Reiniciar Dovecot
echo "Reiniciando Dovecot..."
sudo service dovecot restart

# Configurar SMTP autenticado en Postfix
echo "Configurando autenticación SMTP en Postfix..."
sed -i 's/^smtpd_client_restrictions =.*/smtpd_client_restrictions = permit_mynetworks, permit_sasl_authenticated, reject/' /etc/postfix/main.cf
sed -i 's/^smtpd_recipient_restrictions =.*/smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination/' /etc/postfix/main.cf

# Agregar configuraciones adicionales a Postfix
cat <<EOL >> /etc/postfix/main.cf

# Estas lineas son nuevas
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_authenticated_header = yes
broken_sasl_auth_clients = yes

EOL

# Reiniciar Postfix
echo "Reiniciando Postfix..."
sudo service postfix restart

# Agregar nuevo usuario
echo "Agregando nuevo usuario..."
sudo adduser $USER
newaliases

# Instalar filtros y antivirus
echo "Instalando Amavisd y paquetes necesarios..."
apt install -y amavisd-new arc arj bzip2 cabextract lhasa lzop nomarch p7zip-full pax rpm tnef unrar-free unzip zip

# Configurar filtros en Postfix
echo "Configurando filtros en Postfix..."
cat <<EOL >> /etc/postfix/main.cf

amavis-filter   unix    -   -   n   -   2   smtp
  -o smtp_data_done_timeout=1200
  -o smtp_send_xforward_command=yes
  -o disable_dns_lookups=yes
  -o max_use=20
127.0.0.1:10025 inet    n  -   n   -   -    smtpd
  -o content_filter=
  -o smtpd_delay_reject=no
  -o smtpd_client_restrictions=permit_mynetworks,reject
  -o smtpd_helo_restrictions=
  -o smtpd_sender_restrictions=
  -o smtpd_recipient_restrictions=permit_mynetworks,reject
  -o smtpd_data_restrictions=reject_unauth_pipelining
  -o smtpd_end_of_data_restrictions=
  -o smtpd_restriction_classes=
  -o mynetworks=127.0.0.0/8
  -o smtpd_error_sleep_time=0
  -o smtpd_soft_error_limit=1001
  -o smtpd_hard_error_limit=1000
  -o smtpd_client_connection_count_limit=0
  -o smtpd_client_connection_rate_limit=0
  -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks,no_milters
  -o local_header_rewrite_clients=

EOL

# Reiniciar Postfix
echo "Reiniciando Postfix..."
sudo systemctl restart postfix

# Verificar servicio
echo "Verificando servicio..."
netstat -tap

# Prueba con telnet a Amavis
echo "Prueba con telnet a Amavis..."
telnet 127.0.0.1 10024

# Configurar antivirus
echo "Configurando antivirus..."
sed -i 's/#@bypass_virus_checks_maps = (/@bypass_virus_checks_maps = (/' /etc/amavis/conf.d/15-content_filter_mode
sed -i 's/bypass_virus_checks,/   \%bypass_virus_checks, \@bypass_virus_checks_acl, \$bypass_virus_checks_re);/' /etc/amavis/conf.d/15-content_filter_mode

sudo adduser clamav amavis
sudo systemctl restart amavis
sudo systemctl restart clamav-daemon

# Configurar antispam
echo "Configurando antispam..."
sed -i 's/#@bypass_spam_checks_maps = (/@bypass_spam_checks_maps = (/' /etc/amavis/conf.d/15-content_filter_mode
sed -i 's/bypass_spam_checks,/   \%bypass_spam_checks, \@bypass_spam_checks_acl, \$bypass_spam_checks_re);/' /etc/amavis/conf.d/15-content_filter_mode

# Configurar Amavis usuario
echo "Configurando Amavis usuario..."
cat <<EOL > /etc/amavis/conf.d/50-user
use strict;

#
# Place your configuration directives here.  They will override those in
# earlier files.
#
# See /usr/share/doc/amavisd-new/ for documentation and examples of
# the directives you can use in this file
#
\$sa_spam_subject_tag = '***SPAM*** ';
\$sa_tag_level_deflt  = undef;  # add spam info headers if at, or above that level
\$sa_tag2_level_deflt = 6.31;   # add 'spam detected' headers at that level
\$sa_kill_level_deflt = 9999;   # triggers spam evasive actions

#------------ Do not modify anything below this line -------------
1;  # ensure a defined return
EOL

sudo systemctl restart amavis

echo "Configuración completa."
