#!/bin/bash
Version=`cat /etc/redhat-release |grep "CentOS Linux release 7"`
echo -e "\033[32m Please enter the path(Example: /home/jjzb/vol1/redis): \033[0m"
read Dir
echo -e "\033[32m Please enter the running user: \033[0m"
read User
echo -e "\033[32m Please enter the redis password: \033[0m"
read Pwd
if [ ! -d "$Dir" ]; then
yum -y install gcc gcc-c++ libstdc++-devel  tcl  wget vim tree gcc gcc-c++ autoconf  curl-devel   ruby ruby-devel rubygems rpm-build 
mkdir -p $Dir && cd  $Dir             
echo -e "\033[32m Download redis3.2.6... \033[0m"                               
wget http://mirror.cnop.net/redis/redis-3.2.6.tar.gz
tar -zxvf redis-3.2.6.tar.gz && rm -rf  redis-3.2.6.tar.gz && mv  redis-3.2.6/*  $Dir && rm -rf redis-3.2.6                          
make
echo -e "\033[32m make successed... \033[0m"
make test 
echo -e "\033[32m make test successed... \033[0m"
sed -i 's/daemonize no/daemonize yes/'  $Dir/redis.conf
echo "maxmemory 6442450944"  >>$Dir/redis.conf
echo "masterauth $Pwd"  >>$Dir/redis.conf
echo "requirepass $Pwd"  >>$Dir/redis.conf
sed -i "s@bind 127.0.0.1@#bind 127.0.0.1@g" $Dir/redis.conf
chown $User.$User  $Dir
cp $Dir/src/redis-trib.rb  /usr/local/bin/
cp $Dir/src/redis-cli   /usr/local/bin/
cp $Dir/src/redis-server   /usr/local/bin/
cp $Dir/src/redis-sentinel /usr/local/bin/
chown $User.$User  /usr/local/bin/redis*
sleep 1
echo -e "\033[32m Starting redis... \033[0m"
su - $User -c "redis-server $Dir/redis.conf"
sleep 1
echo -e "\033[32m Start is successed. \033[0m"
if [ ! -n "$Version" ]; then 
  #for centos 6,5
  echo  "su - $User -c \"redis-server $Dir/redis.conf\"" >> /etc/rc.local
  else
  #for centos 7+
  echo  "su - $User -c \"redis-server $Dir/redis.conf\"" >> /etc/rc.local
fi
# echo -e "\033[32m Seting iptables... \033[0m"
# /sbin/iptables -I INPUT -p tcp --dport 6379 -j ACCEPT
# /etc/rc.d/init.d/iptables save
# service iptables restart
ps -ef|grep redis
echo -e "\033[32m Install is successed. \033[0m"

else 
echo -e "\033[31m Warning :  the program is installed, the script will exit. \033[0m"
fi