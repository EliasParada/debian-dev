#!/bin/bash

# Script: configurar_subversion.sh
# Descripción: Instala y configura Subversion

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 <opciones>"
    echo
    echo "Opciones:"
    echo "  --group GROUP          - Nombre del grupo"
    echo "  --project PROYECT      - Nombre del proyecto"
    echo "  --user USER            - Nombre del usuario"
    echo "  --dir DIR              - Directorio de trabajo (opcional)"
    echo "  --file FILE            - Nombre del archivo (opcional)"
    echo "  --message MESSAGE      - Mensaje del archivo (opcional)"
    echo "  --commit COMMIT        - Mensaje del commit (opcional)"
    echo "  --update-message UPDATE_MESSAGE - Mensaje de actualización (opcional)"
    echo "  --update-commit UPDATE_COMMIT - Mensaje de actualización del commit (opcional)"
}

# Variables
GROUP=""
PROYECT=""
USER=""
DIR="svn_test"
FILE="testfile.txt"
MESSAGE="Texto de prueba"
COMMIT="Commit inicial"
UPDATE_MESSAGE="Actualización de texto"
UPDATE_COMMIT="Commit de actualización"

# Obtener opciones
while [[ "$1" != "" ]]; do
    case $1 in
        --group )             shift
                              GROUP=$1
                              ;;
        --project )           shift
                              PROYECT=$1
                              ;;
        --user )              shift
                              USER=$1
                              ;;
        --dir )               shift
                              DIR=$1
                              ;;
        --file )              shift
                              FILE=$1
                              ;;
        --message )           shift
                              MESSAGE=$1
                              ;;
        --commit )            shift
                              COMMIT=$1
                              ;;
        --update-message )    shift
                              UPDATE_MESSAGE=$1
                              ;;
        --update-commit )     shift
                              UPDATE_COMMIT=$1
                              ;;
        -h | --help )         mostrar_ayuda
                              exit
                              ;;
        * )                   mostrar_ayuda
                              exit 1
    esac
    shift
done

# Comprobar parámetros obligatorios
if [[ -z $GROUP ]] || [[ -z $PROYECT ]] || [[ -z $USER ]]; then
    echo "Faltan parámetros obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar Subversion
echo "Instalando Subversion..."
apt-get install -y subversion subversion-tools

# Crear grupo y directorio
echo "Creando grupo y directorio..."
sudo groupadd $GROUP
mkdir -p /var/lib/svn

# Crear repositorio
echo "Creando repositorio..."
svnadmin create --fs-type fsfs /var/lib/svn/$PROYECT
chown -R www-data:$GROUP /var/lib/svn/$PROYECT
chmod -R 770 /var/lib/svn/$PROYECT

# Agregar usuario al grupo
echo "Agregando usuario al grupo..."
sudo addgroup $USER $GROUP

# Ver registro del repositorio
echo "Mostrando registro del repositorio..."
svn log file:///var/lib/svn/$PROYECT

# Crear directorio de prueba y archivo
echo "Creando directorio de prueba y archivo..."
mkdir -p ~/$DIR
cd ~/$DIR
echo $MESSAGE > $FILE

# Agregar archivo al repositorio
echo "Agregando archivo al repositorio..."
svn add $FILE
svn commit -m "$COMMIT"

# Actualizar archivo
echo "Actualizando archivo..."
echo $UPDATE_MESSAGE >> $FILE
svn commit -m "$UPDATE_COMMIT"

echo "Configuración de Subversion completada."
