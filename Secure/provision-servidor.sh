#!/bin/bash
set -e

apt update -y
apt install -y vsftpd openssl ftp

# Crear usuarios
useradd -m luis || true
useradd -m maria || true
useradd -m miguel || true

echo "luis:1234" | chpasswd
echo "maria:1234" | chpasswd
echo "miguel:1234" | chpasswd

# Archivos de prueba
su - luis -c "touch luis1.txt luis2.txt"
su - maria -c "touch maria1.txt maria2.txt"

echo "maria" > /etc/vsftpd.chroot_list

# Backup configuración
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Configuración vsftpd
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
listen_ipv6=NO

ftpd_banner=--- Welcome to the FTP server of 'sistema.sol'---

anonymous_enable=YES
anon_root=/srv/ftp
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO

local_enable=YES
write_enable=YES

connect_from_port_20=YES

idle_session_timeout=720

max_clients=15

local_max_rate=5242880
anon_max_rate=2097152


chroot_local_user=YES
allow_writeable_chroot=YES


chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

pam_service_name=vsftpd
secure_chroot_dir=/var/run/vsftpd/empty

# CERTIFICADO
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

# Certificado SSL
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/ssl/certs/example.test.pem \
-out /etc/ssl/certs/example.test.pem \
-subj "/C=ES/O=sistema.sol/CN=ftp.sistema.sol"

# Permisos FTP anónimo
chown -R root:ftp /srv/ftp
chmod -R 555 /srv/ftp

systemctl restart vsftpd
systemctl enable vsftpd
