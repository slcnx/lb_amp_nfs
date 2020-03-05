read -p 'lamp1 ip: ' lamp1
read -p 'lamp2 ip: ' lamp2
read -p 'nfs-server ip: ' nfs
read -p 'lb ip: ' lb
echo lamp1 $lamp1
echo $lamp2
echo nfs $nfs
echo $lb
echo current $current



# 生成/etc/hosts 
cp /etc/hosts{,.bak.$RANDOM}
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
$lamp1 lamp1
$lamp2 lamp2
$nfs nfs-server
$lb  lb
EOF

# 配置主机名
echo config hostname
ssh lamp1 hostnamectl set-hostname lamp1
ssh lamp2 hostnamectl set-hostname lamp2
ssh nfs-server hostnamectl set-hostname nfs-server
ssh lb hostnamectl set-hostname lb

# 生成ssh-keygen
# 为所有主机添加公钥
echo add public key
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 2048 -P '' -f ~/.ssh/id_rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub lamp1
ssh-copy-id -i ~/.ssh/id_rsa.pub lamp2
ssh-copy-id -i ~/.ssh/id_rsa.pub nfs-server
ssh-copy-id -i ~/.ssh/id_rsa.pub lb

# 所有主机暂停iptables, selinux
ssh lb systemctl stop firewalld.service;systemctl disable firewalld.service;setenforce 0;sed -i 's@SELINUX=.*@SELINUX=disabled@g' /etc/selinux/config
ssh nfs-server systemctl stop firewalld.service;systemctl disable firewalld.service;setenforce 0;sed -i 's@SELINUX=.*@SELINUX=disabled@g' /etc/selinux/config
ssh lamp1 systemctl stop firewalld.service;systemctl disable firewalld.service;setenforce 0;sed -i 's@SELINUX=.*@SELINUX=disabled@g' /etc/selinux/config
ssh lamp2 systemctl stop firewalld.service;systemctl disable firewalld.service;setenforce 0;sed -i 's@SELINUX=.*@SELINUX=disabled@g' /etc/selinux/config

# 统一主机解析名文件
scp /etc/hosts lamp1:/etc/hosts
scp /etc/hosts lamp2:/etc/hosts
scp /etc/hosts nfs-server:/etc/hosts
scp /etc/hosts lb:/etc/hosts

