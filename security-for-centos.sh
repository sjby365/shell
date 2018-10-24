#!/bin/bash
#######说明：运行前请先关闭云锁等防护工具  17-12-11 14:44 ###########
Path=/etc/login.defs  
#######Default passwd length#######
echo "Set default passwd length and login.defs..."
cp $Path  /etc/login.defs.bak$(date +"%Y%m%d%H%M")
sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	90/' $Path
sed -i 's/PASS_MIN_LEN	5/PASS_MIN_LEN	12/' $Path
sed -i 's/PASS_WARN_AGE	7/PASS_WARN_AGE	30/' $Path
sed -i 's/UMASK           077/UMASK	027/' $Path
####### sshd #######
Path=/etc/ssh/sshd_config
Version=`cat /etc/redhat-release |grep "CentOS Linux release 7"`
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 600/' $Path
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 0/' $Path
if [ ! -n "$Version" ]; then 
#for centos 7-
service sshd restart
else  
#for centos 7+
systemctl restart  sshd.service
fi
#######system seting#######
echo "system seting..."
#chmod -R 600 /etc/services
chmod -R 644 /etc/services
#/etc/services   阿里云建议600，实际建议644
chmod -R 600 /etc/security
chmod 644 /etc/group              
echo -e "\033[32m Seting ssh timeout ... \033[0m"
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/' /etc/ssh/sshd_config
echo -e "\033[32m Done \033[0m"
echo -e "\033[32m Prohibit Ping  \033[0m"
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo -e "\033[32m Done \033[0m"