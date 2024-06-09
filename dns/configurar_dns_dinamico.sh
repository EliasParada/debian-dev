#!/bin/bash

# Script: configurar_dns_dinamico.sh
# Descripción: Configura el cliente DNS dinámico (ddclient)

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --host HOST"
    echo
    echo "Opciones:"
    echo "  --host HOST           - Nombre del host (ej. myserver.dyndns.org)"
    echo "  -h, --help            - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
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

if [[ -z "$HOST" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar ddclient
echo "Instalando ddclient..."
apt-get install -y ddclient

# Configurar /etc/ddclient.conf
echo "Configurando /etc/ddclient.conf..."
cat /etc/ddclient.conf

# Reiniciar ddclient
echo "Reiniciando ddclient..."
sudo service ddclient restart

# Verificar configuración
echo "Verificando configuración..."
sudo ddclient -v
nslookup $HOST

echo "Configuración de DNS dinámico completada."
