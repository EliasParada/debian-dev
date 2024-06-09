#!/bin/bash

# Script: configurar_servidor_email.sh
# Descripción: Instala y configura un servidor de correo electrónico con Dovecot y Postfix

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 <opciones>"
    echo
    echo "Opciones:"
    echo "  --user USER          - Nombre del usuario"
    echo "  --host HOST          - Nombre del host"
    echo "  --full-host FULL_HOST - Nombre completo del host"
    echo "  --network NETWORK    - Red (ej. 192.168.1.0)"
    echo "  --ip IP              - Dirección IP del servidor"
    echo "  --storage STORAGE    - Límite de almacenamiento (ej. 10G)"
}

# Variables
USER=""
HOST=""
FULL_HOST=""
NETWORK=""
IP=""
STORAGE="10G"

# Obtener opciones
while [[ "$1" != "" ]]; do
    case $1 in
        --user )          shift
                          USER=$1
                          ;;
        --host )          shift
                          HOST=$1
                          ;;
        --full-host )     shift
                          FULL_HOST=$1
                          ;;
        --network )       shift
                          NETWORK=$1
                          ;;
        --ip )            shift
                          IP=$1
                          ;;
        --storage )       shift
                          STORAGE=$1
                          ;;
        -h | --help )     mostrar_ayuda
                          exit
                          ;;
        * )               mostrar_ayuda
                          exit 1
    esac
    shift
done

# Comprobar parámetros obligatorios
if [[ -z $USER ]] || [[ -z $HOST ]] || [[ -z $FULL_HOST ]] || [[ -z $NETWORK ]] || [[ -z $IP ]]; then
    echo "Faltan parámetros obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar Dovecot
echo "Instalando Dovecot..."
apt-get install -y dovecot-imapd

# Configurar Dovecot
echo "Configurando Dovecot..."
cat <<EOL > /etc/dovecot/local.conf
mail_location = maildir:~/Maildir
## Plugins
mail_plugins = \$mail_plugins quota
protocol imap {
  mail_plugins = \$mail_plugins imap_quota
}
plugin {
  quota = maildir
  quota_rule = *:storage=$STORAGE
}
## Autentificación
auth_mechanisms = plain login
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
  }
}
EOL

# Crear directorios de correo
echo "Creando directorios de correo..."
su - $USER -c "maildirmake.dovecot ~/Maildir"
maildirmake.dovecot /etc/skel/Maildir
sudo service dovecot restart

# Verificar configuración de Dovecot
echo "Verificando configuración de Dovecot..."
sudo dovecot -n

# Instalar Postfix
echo "Instalando Postfix..."
apt-get install -y postfix postfix-doc

# Configurar Postfix
echo "Configurando Postfix..."
cat <<EOL >> /etc/postfix/main.cf
mydestination = $HOST, $FULL_HOST, localhost.$HOST, localhost
mynetworks = 127.0.0.0/8, $NETWORK/24
inet_interfaces = 127.0.0.1, $IP
home_mailbox = Maildir/
smtpd_client_restrictions = permit_mynetworks, reject
smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination
smtpd_helo_restrictions = reject_unknown_sender_domain
smtpd_sender_restrictions = reject_unknown_sender_domain
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_authenticated_header = yes
broken_sasl_auth_clients = yes
EOL

# Reiniciar Postfix
echo "Reiniciando Postfix..."
sudo service postfix restart

# Autenticación
echo "Configurando autenticación..."
cat <<EOL >> /etc/postfix/main.cf
smtpd_client_restrictions = permit_mynetworks, permit_sasl_authenticated, reject
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
EOL

sudo service dovecot restart
sudo service postfix restart

# Agregar usuario
echo "Agregando usuario..."
sudo adduser $USER
newaliases

# Configurar filtros
echo "Configurando filtros..."
apt install -y amavisd-new
apt install -y arc arj bzip2 cabextract lhasa lzop nomarch p7zip-full pax rpm tnef unrar-free unzip zip

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

sudo systemctl restart postfix
netstat -tap

# Configurar antivirus
echo "Configurando antivirus..."
nano /etc/amavis/conf.d/15-content_filter_mode
# Buscar y reemplazar las siguientes líneas
sed -i 's/#@bypass_virus_checks_maps = (/ @bypass_virus_checks_maps = (/' /etc/amavis/conf.d/15-content_filter_mode
sed -i 's/#   \%bypass_virus_checks,/   \%bypass_virus_checks, \@bypass_virus_checks_acl, \$bypass_virus_checks_re);/' /etc/amavis/conf.d/15-content_filter_mode

sudo adduser clamav amavis
sudo systemctl restart amavis
sudo systemctl restart clamav-daemon

# Configurar antispam
echo "Configurando antispam..."
nano /etc/amavis/conf.d/15-content_filter_mode
# Buscar y reemplazar las siguientes líneas
sed -i 's/#@bypass_spam_checks_maps = (/ @bypass_spam_checks_maps = (/' /etc/amavis/conf.d/15-content_filter_mode
sed -i 's/#   \%bypass_spam_checks,/   \%bypass_spam_checks, \@bypass_spam_checks_acl, \$bypass_spam_checks_re);/' /etc/amavis/conf.d/15-content_filter_mode

nano /etc/amavis/conf.d/50-user
# Agregar la configuración siguiente una línea antes de "#------------ Do not modify anything below this line -------------"
echo "\$sa_spam_subject_tag = '***SPAM*** ';" >> /etc/amavis/conf.d/50-user
echo "\$sa_tag_level_deflt  = undef;" >> /etc/amavis/conf.d/50-user
echo "\$sa_tag2_level_deflt = 6.31;" >> /etc/amavis/conf.d/50-user
echo "\$sa_kill_level_deflt = 9999;" >> /etc/amavis/conf.d/50-user

sudo service amavis restart

echo "Configuración del servidor de correo completada."
