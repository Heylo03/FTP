#!/bin/bash

apt-get update -y
apt-get install -y vsftpd ftp

# Crear estructura FTP
mkdir -p /srv/ftp

# Copiar mensaje
cp /vagrant/README /srv/ftp/README

# Permisos correctos
chown -R ftp:ftp /srv/ftp
chmod -R 555 /srv/ftp

# Copiar configuración
cp /vagrant/vsftpd.conf /etc/vsftpd.conf

# Arrancar servicio
systemctl restart vsftpd
systemctl enable vsftpd
