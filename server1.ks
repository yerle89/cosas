# Deshabilitamos el cortafuegos
firewall ‐‐disabled
# Instalar/actualizar sistema operativo
install
# Medio de arranque por red
url ‐‐url=”http://10.0.100.1/cblr/links/CentOS7-x86_64/”
# Hash del password de Root obtenido anteriormente
rootpw ‐‐iscrypted $1$2i/qD1zw$v6VeHIt56YSFlAV8T5Cut1
# Información red  
network ‐‐bootproto=static ‐‐ip=10.0.100.12 ‐‐netmask=255.255.255.0
‐‐gateway=10.0.100.1 ‐‐nameserver=10.0.100.1,8.8.8.8 ‐‐device=enp0s3
‐‐hostname=cluster2 ‐‐onboot=on ‐‐noipv6 ‐‐activate
# Reboot despues de la instalación
reboot
# Tipo de encriptacion
auth  ‐‐enableshadow ‐‐passalgo=sha512
# Usar instalación modo texto
text
firstboot ‐‐disable
# Teclado
keyboard es
# Lenguaje del sistema
lang en_US
# Configuración SElinux  
selinux ‐‐disabled  
# Configuracion LOGS
logging level=info
# Zona Horaria
timezone Europe/Madrid
# Arranque del sistema
bootloader location=mbr
clearpart ‐‐all ‐‐initlabel ‐‐drives=sda
# Particionado del disco duro
part swap ‐‐asprimary  ‐‐fstype=”swap” ‐‐size=1024
part /boot ‐‐fstype xfs ‐‐size=256
part pv.01 ‐‐size=1 ‐‐grow
volgroup root_vg01 pv.01
logvol / ‐‐fstype xfs ‐‐name=lv_01 ‐‐vgname=root_vg01 ‐‐size=1 ‐‐grow
# Paquetes incluidos en la instalacion
%packages
@^minimal
@core
%end
# En post arranque se especifican comandos que se han de ejecutar
%post
yum –y install epel‐release
yum –y update
yum –y upgrade
yum –y install httpd ntp nfs‐utils
yum –y install php wget net‐tools  
# Configuracion NFS
# Creamos un punto de montaje para establecer conexión con en nodo nas.
mkdir –p /mnt/post
mkdir –p /mnt/web
# Creamos una entrada en el fichero /etc/fstab para montar el directorio
compartido del nodo de almacenamiento
echo “10.0.100.5:/var/post /mnt/post nfs defaults,_netdev,rw 0 0” >>
/etc/fstab
echo “10.0.100.5:/var/web  /mnt/web   nfs defaults,_netdev,rw 0 0 >>
/etc/fstab
mount –a
# Se copian por red todos los ficheros de configuración necesarios para
cada nodo
cat /mnt/post/hosts > /etc/hosts
systemctl disable NetworkManager
#Configuración SSH habilitando el acceso por clave publica sin contraseña
sed –i ‘s/#PermitRootLogin no /PermitRootLogin yes/g’ /etc/sshd_config
mkdir –p –mode=700 /root/.ssh
cat >> /root/.ssh/authorized_keys << EOF
ssh‐rsa xxxxxxxxxxxxxxxxxxx (contenido del fichero que contiene la clave
publica, /root/.ssh/id_rsa.pub)
EOF
chmod 600 /root/.ssh/authorized_keys  
systemctl reload sshd
systemctl start httpd
systemctl enable httpd
# Configuracion NTP
\cp /mnt/post/ntp.conf /etc/ntp.conf
systemctl start ntpd
systemctl enable ntpd  
%end
