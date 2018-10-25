#/bin/bash
Dir=/usr/local/frp
yum -y install wget
mkdir -p $Dir && cd $Dir 
wget http://mirror.cnop.net/frp/frp_0.13.0_linux_amd64.tar.gz
tar -zxvf frp_0.13.0_linux_amd64.tar.gz && rm -rf frp_0.13.0_linux_amd64.tar.gz 
mv $Dir/frp_0.13.0_linux_amd64/* ./ && rm -rf $Dir/frp_0.13.0_linux_amd64
cd $Dir && rm -rf frps frps.ini 
#/bin/bash
echo "
[common]
server_addr = 23.105.195.x
server_port = 7000

[ssh]
type = tcp
local_ip = 192.168.20.126
local_port = 22
remote_port = 6000

[web]
type = http         
local_port = 8181   
custom_domains = vpn.xrk.org

[mysql]
type = tcp
local_port = 3307
remote_port = 13306
">$Dir/frpc.ini
echo "Please input the service ip:"
read s_ip
sed -i "s@23.105.195.x@$s_ip@g" $Dir/frpc.ini

echo "Please input the local addr:"
read l_ip
sed -i "s@192.168.20.126@$l_ip@g" $Dir/frpc.ini
echo "Please input the mysql port:"
read mysql_port
sed -i "s@3307@$mysql_port@g" $Dir/frpc.ini

echo "Please input the web port:"
read web_port
sed -i "s@8181@$web_port@g" $Dir/frpc.ini
echo "
[Unit]
Description=FRP Client Daemon
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frpc -c /usr/local/frp/frpc.ini
Restart=always
RestartSec=20s
User=nobody

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/frpc.service
echo "start frpc:"
systemctl daemon-reload && systemctl start frpc && systemctl enable frpc
echo "Done"