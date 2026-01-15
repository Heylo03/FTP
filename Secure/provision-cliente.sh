#!/bin/bash
set -e

apt update -y
apt install -y ftp

# Usuario pepe
useradd -m pepe || true
echo "pepe:1234" | chpasswd

# Directorio y archivo
su - pepe -c "
mkdir -p /home/pepe/pruebasFTP
cd /home/pepe/pruebasFTP
echo 'Archivo de prueba FTP' > datos1.txt
"
