# 展开
tar Pvxf  dns-master-slave.tar.gz

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


注意：仅需要修改mdns, sdns为合适的ip


对DNS的2个主机进行公钥认证
执行脚本 ssh-copy-id.sh

vi roles/dnsmaster/dns.yml
 
 { role: dnsmaster, allow_recursion: '172.16.0.16/16;', zone: magedu.com, slaves: 172.16.0.178; , domain: magedu.com., serial: 2020031411, refresh: 1H, retry: 5M, expire: 3D, ttl: 1D, ns1: 172.16.0.172, ns2: 172.16.0.171, mx1: 1.1.1.1, mx2: 2.2.2.2, www1: 172.16.0.171, www2: 172.16.0.178, php: 172.16.0.172, mysql: 172.16.0.173, files: 172.16.0.177, ansible: 172.16.0.177, rsyslog: 172.16.0.177 }
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

 { role: dnsslave, allow_recursion: '172.16.0.16/16;', zone: magedu.com, masters: 172.16.0.177; }
	allow_recursion: /etc/named.conf中allow-recursion中的地址, ip或net/prefix 表示允许哪些地址来递归
	zone：/etc/named.rfc1912.zone中定义zone 例如: magedu.com
	masters: masters {} 的值, 没有下一级从, 就应该关闭传送
	/etc/named.rfc1912.zones
		zone "{{ zone }}" IN {
			type slave;
			file "slaves/{{ zone }}.zone";
			masters { {{ masters }} };
			allow-transfer { none; };
		};

	


# 运行
```
# ansible-playbook --syntax-check /etc/ansible/roles/dnsmaster/dns.yml 
# ansible-playbook -C /etc/ansible/roles/dnsmaster/dns.yml
# ansible-playbook  /etc/ansible/roles/dnsmaster/dns.yml
```


# 所有主机添加解析文件
ansible all -m copy "src=resolv.conf dest=/etc/resolv.conf"

# 安装samba
# ansible-playbook  /etc/ansible/roles/samba-server/smb.yml

# 安装httpd
# ansible-playbook  /etc/ansible/roles/httpd/httpd.yml

# 安装php-fpm, 允许的主机必须为主机名
# ansible-playbook  /etc/ansible/roles/php-fpm/php-fpm.yml

# 安装mariadb-server
# ansible-playbook /etc/ansible/roles/mariadb-server/mariadb-server.yml


# httpd, php-fpm 挂载samba, /etc/fstab自启动, 生成网页文件


