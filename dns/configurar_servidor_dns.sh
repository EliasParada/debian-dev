#!/bin/bash

# Script: configurar_servidor_dns.sh
# Descripción: Configura el servidor DNS

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --direct DIRECT --reverse REVERSE --ip IP --server-full SERVER_FULL --virtual-ip VIRTUAL_IP --router ROUTER"
    echo
    echo "Opciones:"
    echo "  --direct DIRECT        - Dominio directo (ej. server.lan)"
    echo "  --reverse REVERSE      - Dominio inverso (ej. 2.168.192)"
    echo "  --ip IP                - Dirección IP del servidor (ej. 192.168.2.14)"
    echo "  --server-full SERVER_FULL - Nombre completo del servidor (ej. debian.server.lan)"
    echo "  --virtual-ip VIRTUAL_IP   - Dirección IP virtual (ej. 192.168.2.15)"
    echo "  --router ROUTER        - Dirección IP del router (ej. 192.168.2.1)"
    echo "  -h, --help             - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --direct)
            DIRECT="$2"
            shift
            ;;
        --reverse)
            REVERSE="$2"
            shift
            ;;
        --ip)
            IP="$2"
            shift
            ;;
        --server-full)
            SERVER_FULL="$2"
            shift
            ;;
        --virtual-ip)
            VIRTUAL_IP="$2"
            shift
            ;;
        --router)
            ROUTER="$2"
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

if [[ -z "$DIRECT" || -z "$REVERSE" || -z "$IP" || -z "$SERVER_FULL" || -z "$VIRTUAL_IP" || -z "$ROUTER" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Configurar /etc/bind/named.conf.local
echo "Configurando /etc/bind/named.conf.local..."
NAMED_LOCAL="/etc/bind/named.conf.local"

cat <<EOL > $NAMED_LOCAL
//
// Do any local configuration here
//
zone "$DIRECT" { 
   type master;
   file "/etc/bind/db.$DIRECT";
};
zone "$REVERSE.in-addr.arpa" { 
   type master;
   file "/etc/bind/db.$REVERSE";
};
EOL

sudo named-checkconf

# Configurar zona directa
echo "Configurando zona directa..."
cp /etc/bind/db.local /etc/bind/db.$DIRECT

cat <<EOL > /etc/bind/db.$DIRECT
\$TTL 3D
@  IN SOA $SERVER_FULL.  root.$DIRECT. (
                 2        ; Serial
            604800        ; Refresh
             86400        ; Retry
           2419200        ; Expire
            604800 )      ; Negative Cache TTL

;
@             IN    NS   $SERVER_FULL.
@             IN    MX   10 mail.$DIRECT.
$SERVER_FULL        IN    A    $IP
mail          IN    A    $IP
$DIRECT    IN    A    $IP
$(hostname)       IN    A    $IP
virtual       IN    A    $VIRTUAL_IP
router        IN    A    $ROUTER
gateway       IN    CNAME router
proxy         IN    CNAME   $(hostname)
www          IN   CNAME   $(hostname)
ftp        IN     CNAME   $(hostname)
EOL

# Configurar zona inversa
echo "Configurando zona inversa..."
cp /etc/bind/db.127 /etc/bind/db.$REVERSE

cat <<EOL > /etc/bind/db.$REVERSE
\$TTL 3D
@  IN SOA $SERVER_FULL.  root.$DIRECT. (
                 2        ; Serial
            604800        ; Refresh
             86400        ; Retry
           2419200        ; Expire
            604800 )      ; Negative Cache TTL

;
@        IN    NS     $SERVER_FULL.
$(echo $IP | awk -F. '{print $4}')       IN    PTR    $SERVER_FULL.
$(echo $IP | awk -F. '{print $4}')       IN    PTR    mail.$DIRECT.
$(echo $VIRTUAL_IP | awk -F. '{print $4}')       IN    PTR    virtual.$DIRECT.
1        IN    PTR    router.$DIRECT.
EOL

# Verificar configuración de zonas
echo "Verificando configuración de zonas..."
sudo named-checkzone $DIRECT /etc/bind/db.$DIRECT
sudo named-checkzone $REVERSE.in-addr.arpa /etc/bind/db.$REVERSE

# Reiniciar Bind9
echo "Reiniciando Bind9..."
systemctl restart bind9

# Probar configuración DNS
echo "Probando configuración DNS..."
nslookup $(hostname)
nslookup virtual
nslookup gateway
nslookup $VIRTUAL_IP

echo "Configuración del servidor DNS completada."
