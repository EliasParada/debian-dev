#!/bin/bash

# Script: configurar_antispam.sh
# Descripción: Instala y configura el antispam SpamAssassin

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo
    echo "Este script no requiere opciones adicionales."
    echo
}

# Instalar SpamAssassin
echo "Instalando SpamAssassin..."
apt-get install -y spamassassin spamc

# Habilitar SpamAssassin
echo "Habilitando SpamAssassin..."
sudo update-rc.d spamassassin enable

# Configurar /etc/default/spamassassin
echo "Configurando /etc/default/spamassassin..."
sed -i 's/^#CRON=.*/CRON=1/' /etc/default/spamassassin

# Reiniciar SpamAssassin
echo "Reiniciando SpamAssassin..."
sudo service spamassassin restart

# Descargar archivo de prueba
cd ~/Descargas/
echo "Descargando archivo de prueba..."
wget http://spamassassin.apache.org/gtube/gtube.txt

# Verificar SpamAssassin
echo "Verificando SpamAssassin..."
spamc < gtube.txt

# Eliminar archivo de prueba
echo "Eliminando archivo de prueba..."
rm gtube.txt

echo "Instalación y configuración de SpamAssassin completada."
