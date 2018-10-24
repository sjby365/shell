#!/bin/bash
#2018-05-21 cnetos7+
Vname=tengine-2.2.1.tar.gz
Version=`cat /etc/redhat-release |grep "CentOS Linux release 7"`
#Firewalld=`ps -ef|grep "/usr/sbin/firewalld"`
echo -e "\033[32m Please enter the installation directory ( Example: /home/jjzb/vol1/nginx ) :    \033[0m"
read Dir
if [ -e $Dir ]; then
#Folder name exists in system
echo -e "\033[32m Ready to Install.   \033[0m"
else
#Folder name no exists in system
echo -e "\033[32m Create $Dir   \033[0m"
mkdir $Dir
fi
echo -e "\033[32m Install lib... \033[0m"
yum -y install jemalloc pcre* openssl* unzip wget zip
echo -e "\033[32m Download install package ... \033[0m"
cd /home  && wget http://mirror.xrk.org/web/tengine/$Vname && wget http://mirror.cnop.net/yunsuo/yunsuo-nginx-plugin-master.zip
echo -e "\033[32m Unzip package... \033[0m"
tar xvf $Vname  && unzip yunsuo-nginx-plugin-master.zip
cd tengine-2.2.1 && ./configure --prefix=$Dir --with-http_ssl_module --with-http_concat_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_upstream_check_module  --add-module=../nginx-plugin-master
make && make install
cd ../  && rm -rf tengine-2.2.1* && rm -rf nginx-plugin-master*  && rm -rf  yunsuo-nginx-plugin-master.zip
cp $Dir/sbin/nginx   /usr/local/bin/ && chmod +x /usr/local/bin/nginx && cp $Dir/sbin/nginx /usr/sbin/ && chmod +x /usr/sbin/nginx
cd /etc/init.d && wget http://mirror.cnop.net/web/tengine/tengine && mv tengine nginx 
sed -i "s@/home/jjzb/vol1/nginx@$Dir@g" nginx && chmod +x nginx

if [ ! -n "$Version" ]; then 
#for centos 7-
#echo -e "\033[32m  Seting firewall for centos ... \033[0m"
#iptables -I INPUT -p tcp -m multiport --dports 80 -j ACCEPT
#service iptables save 
#service iptables restart  
echo -e "\033[32m starting nginx... \033[0m"
service nginx start
echo "service nginx start" >>/etc/rc.d/rc.local
else  
#for centos 7
#if [ ! -n "$Firewalld" ]; then 
#echo "Skip firewall."
#else
#firewall-cmd --zone=public --add-port=80/tcp --permanent
#echo -e "\033[32m Restart firewall ... \033[0m"
#systemctl restart firewalld.service
#fi
echo -e "\033[32m starting nginx... \033[0m"
chkconfig --add nginx && systemctl daemon-reload && /sbin/chkconfig  nginx on && systemctl start nginx.service
fi

Url=http://127.0.0.1
Code=`curl -I -m 10 -o /dev/null -s -w %{http_code}  $Url`
if [ $Code = "403" ]; then
#url visit ...
echo -e "\033[32m install  is succeed... \033[0m"
echo -e "\033[32m Nginx default startup user is nobody please change to another user... \033[0m"
else
echo -e "\033[31m Error : Do not start the nginx,please check whether the installation is successful. \033[0m"
fi