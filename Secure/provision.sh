#!/bin/bash

set -e

echo "== Actualizando sistema =="
apt update -y

echo "== Instalando vsftpd y cliente ftp =="
apt install -y vsftpd ftp openssl

echo "== Creando usuarios =="
useradd -m luis || true
useradd -m maria || true
useradd -m miguel || true

echo "luis:1234" | chpasswd
echo "maria:1234" | chpasswd
echo "miguel:1234" | chpasswd

echo "== Creando archivos de prueba =="
su - luis -c "touch luis1.txt luis2.txt"
su - maria -c "touch maria1.txt maria2.txt"

echo "== Configurando chroot list =="
echo "maria" > /etc/vsftpd.chroot_list

echo "== Backup configuración original =="
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

echo "== Configurando vsftpd =="
cat > /etc/vsftpd.conf << 'EOF'
#
# 1. Modo standalone IPv4
listen=YES
listen_ipv6=NO

#
# 2. Mensaje de bienvenida
ftpd_banner=--- Welcome to the FTP server of 'sistema.sol'---

#
# 3. Usuarios anónimos
anonymous_enable=YES
anon_root=/srv/ftp
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO

#
# 4. Usuarios locales
local_enable=YES
write_enable=YES

#
# 5. Puerto 20 para datos
connect_from_port_20=YES

#
# 6. Timeout
idle_session_timeout=720

#
# 7. Conexiones máximas
max_clients=15

#
# 8. Ancho de banda
local_max_rate=5242880
anon_max_rate=2097152

#
# 9. Enjaulado
chroot_local_user=YES
allow_writeable_chroot=YES

#
# 10. Usuarios no enjaulados
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

#
# 11. Sistema
pam_service_name=vsftpd
secure_chroot_dir=/var/run/vsftpd/empty

#
# 12. FTP Seguro (FTPS)
ssl_enable=YES
allow_anon_ssl=YES
force_local_logins_ssl=YES
force_local_data_ssl=YES

ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

rsa_cert_file=/etc/ssl/certs/example.test.pem
require_ssl_reuse=NO
EOF

echo "== Creando certificado SSL =="
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/ssl/certs/example.test.pem \
-out /etc/ssl/certs/example.test.pem \
-subj "/C=ES/ST=Andalucia/L=Granada/O=sistema.sol/CN=ftp.sistema.sol"

echo "== Ajustando permisos FTP anónimo =="
chown -R root:ftp /srv/ftp
chmod -R 555 /srv/ftp

echo "== Reiniciando servicio =="
systemctl restart vsftpd
systemctl enable vsftpd

echo "== PROVISION FINALIZADO CORRECTAMENTE =="
