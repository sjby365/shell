#/bin/bash
echo -e "\033[32m Please input the path(Example:/usr/local/frp): \033[0m"
read Dir
yum -y install wget
if [ -e $Dir ]; then
#Folder name exists in system
echo -e "\033[32m Ready to Install.   \033[0m"
else
#Folder name no exists in system
echo -e "\033[32m Create $Dir   \033[0m"
mkdir -p $Dir 
fi
cd $Dir && wget http://mirror.cnop.net/frp/frp_0.13.0_linux_amd64.tar.gz
tar -zxvf frp_0.13.0_linux_amd64.tar.gz && rm -rf frp_0.13.0_linux_amd64.tar.gz 
mv $Dir/frp_0.13.0_linux_amd64/* ./ && rm -rf $Dir/frp_0.13.0_linux_amd64
cd $Dir && rm -rf frpc frpc.ini 
echo "
[common]
bind_port = 7000
vhost_http_port = 6081
">$Dir/frps.ini

echo -e "\033[32m Please input vhost port(Example:6081): \033[0m"
read Vhost_port
sed -i "s@6081@$Vhost_port@g" $Dir/frps.ini

echo "
[Unit]
Description=FRP Client Daemon
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini
Restart=always
RestartSec=20s
User=nobody

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/frps.service
sed -i "s@/usr/local/frp@$Dir@g" /etc/systemd/system/frps.service
echo -e "\033[32m start frps:   \033[0m"
systemctl daemon-reload && systemctl start frps && systemctl enable frps
echo -e "\033[32m Done   \033[0m"