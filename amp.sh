yum -y install https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm
yum -y install httpd php74-php-fpm.x86_64 php74-php-mysql mariadb-server


# skip resolve hostname,  innodb-file-per-table, log-bin
sed -i '/\[mysqld\]/a skip-name-resolve = 1\ninnodb-file-per-table = 1\nlog-bin = master-bin' /etc/my.cnf.d/server.cnf


#
sed -i '$a \pm.status_path = /status\nping.path = /ping\nping.response = pong\nphp_value[session.save_handler] = files\nphp_value[session.save_path]    = /var/opt/php/session' /etc/opt/remi/php74/php-fpm.d/www.conf
install -dv -o 48 -g 48 /var/opt/php/session

cat > /etc/httpd/conf.d/fcgi.conf << EOF
directoryindex index.php
proxyrequests off
proxypassmatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/$1
proxypassmatch ^/(status|ping)$ fcgi://127.0.0.1:9000/$1
EOF
httpd -t
[ $? -eq 0 ] || {
echo httpd config not ok,
exit
}


systemctl start httpd php74-php-fpm mariadb


echo lamp: $(hostname) >> /var/www/html/index.html




