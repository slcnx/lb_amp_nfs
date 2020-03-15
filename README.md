# 展开
tar Pvxf  2httpd-nfs-mariadb_2dns-rsyslog-ansible.tar.gz

# 修改配置
cd /etc/ansible/
# cat hosts
[web]
web[1:2].magedu.com

[php]
php.magedu.com

[mariadb]
mysql.magedu.com
	
[files]
files.magedu.com

[rsyslog]
rsyslog.magedu.com

[ansible]
ansible.magedu.com


[mdns]
172.16.0.177

[sdns]
172.16.0.178


[any:children]
web
php
mariadb
files
rsyslog
ansible
mdns
sdns

[any:vars]
#master dns
allow_recursion='192.168.73.0/24;'
zone=magedu.com
slaves=192.168.73.133;
domain=magedu.com.
serial=2020031412
refresh=1H
retry=5M
expire=3D
ttl=1D
ns1=192.168.73.133
ns2=192.168.73.132
mx1=1.1.1.1
mx2=2.2.2.2
www1=192.168.73.135
www2=192.168.73.128
php=192.168.73.128
mysql=192.168.73.135
files=192.168.73.132
ansible=192.168.73.133
rsyslog=192.168.73.133

#slave dns
masters=192.168.73.132;

# web
name="web {{ ansible_default_ipv4.address }}"
phpfpm_server={{ php }}
phpfpm_port=9000

#mariadb
log_bin=master-log
dbname=wordpress
encoding=utf8mb4
mysql_host=127.0.0.1
mysql_port=3306
mysql_root_pwd=''
loginuser=wpuser
loginpasswd=wppass
priv='wordpress.*:ALL'
loginhost='%'


#php
php_documentroot=/var/www/html
php_session_save_path=/data/php_session
allowed_clients='127.0.0.1,{{ www1 }},{{ www2 }}'

#samba
sharepath=/data/smb/web
commonuser=apache
commonuserid=48
commonusergid=48
password=apache

#mount
mountopts="username=apache,password=apache"
mountpath=/var/www/html
mountsrc=//{{ files }}/mysmb





 
	allow_recursion: /etc/named.conf中allow-recursion中的地址, ip或net/prefix 表示允许哪些地址来递归
	zone：/etc/named.rfc1912.zone中定义zone 例如: magedu.com
	slaves: allow-transfer 的值, 主应该仅允许从ip来传送
	/etc/named.rfc1912.zones
		zone "{{ zone }}" IN {
			type master;
			file "{{ zone }}.zone";
			allow-update { none; };
			allow-transfer { {{ slaves }} };
		};
	
	/var/named/magedu.com.zone
		$TTL 3600
		$ORIGIN {{ domain }}
		@	IN	SOA	@	dnsadmin.{{ domain }}	({{ serial }}	{{ refresh }}	{{ retry }}	{{ expire }}	{{ ttl }})
			IN	NS	ns1	
			IN	NS	ns2	
		ns1	IN	A	{{ ns1 }}	
		ns2	IN	A	{{ ns2 }}

			IN	MX 10	mx2	
			IN	MX 20	mx1	
		mx1	IN	A	{{ mx1 }}
		mx2	IN	A	{{ mx2 }}


		www	IN	A	{{ www1 }}
		www	IN	A	{{ www2 }}
		web	IN	CNAME	www
		web1	IN	A 	{{ www1 }}
		web2	IN	A	{{ www2 }}


		php	IN	A	{{ php }}
		mysql	IN	A	{{ mysql }}
		files	IN	A	{{ files }}
		ansible	IN	A	{{ ansible }}
		rsyslog IN	A	{{ rsyslog }}

	masters: masters {} 的值, 没有下一级从, 就应该关闭传送
	/etc/named.rfc1912.zones
		zone "{{ zone }}" IN {
			type slave;
			file "slaves/{{ zone }}.zone";
			masters { {{ masters }} };
			allow-transfer { none; };
		};

	


1. 更新dns1, dns2, web, php, mysql, files, rsyslog, ansible 的ip
bash  ssh-copy-id.sh

2. 对DNS的2个主机进行公钥认证
ansible-playbook 2httpd-php-fpm-nfs-mariadb-server_2dns-ansible-rsyslog.yml

3. 更新当前主机的/etc/resolv.conf
 bash ssh-copy-id.sh

ansible-playbook 2httpd-php-fpm-nfs-mariadb-server_2dns-ansible-rsyslog.yml


