#!/bin/bash
echo -e "
"
date
echo ""
domain=$(cat /root/domain)
sleep 1
mkdir -p /etc/xray 
echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org 
timedatectl set-ntp true
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chronyd"
systemctl enable chronyd
systemctl restart chronyd
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chrony"
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
sleep 1
echo -e "[ ${green}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v
chronyc tracking -v
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
apt install zip -y
apt install curl pwgen openssl netcat cron -y

# install fail2ban
apt -y install fail2ban

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# blokir torrent
apt install netfilter-persistent -y
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
# / / Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.6.2

## crt xray
systemctl stop nginx
cfkey=$(cat /etc/cfkey)
cfemail=$(cat /etc/cfemail)
gmail=$(cat /etc/gmail)
keyid=$(cat /etc/keyid)
hmac=$(cat /etc/hmac)
export CF_Key=$cfkey
export CF_Email=$cfemail
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server google
/root/.acme.sh/acme.sh --register-account -m $gmail --server google --eab-kid $keyid --eab-hmac-key $hmac
/root/.acme.sh/acme.sh --issue --dns dns_cf -d $domain -d *.$domain --server google -k ec-256 --debug
~/.acme.sh/acme.sh --installcert -d $domain --fullchain-file /etc/xray/xray.crt --key-file /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)
# xray config
cat > /etc/xray/config.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
   {
     "listen": "127.0.0.1",
     "port": "14016",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               {
                 "id": "${uuid}"                 
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vless"
          }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "23456",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0
#vmess
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vmess"
          }
        }
     },
    {
      "listen": "127.0.0.1",
      "port": "25432",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",		
           "clients": [
              {
                 "password": "${uuid}"
#trojanws
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": {
               "path": "/trojan-ws"
            }
         }
     },
    {
         "listen": "127.0.0.1",
        "port": "30300",
        "protocol": "shadowsocks",
        "settings": {
           "clients": [
           {
           "method": "aes-256-gcm",
          "password": "${uuid}"
#ssws
           }
          ],
          "network": "tcp,udp"
       },
       "streamSettings":{
          "network": "ws",
             "wsSettings": {
               "path": "/ss-ws"
           }
        }
     },	
      {
        "listen": "127.0.0.1",
     "port": "24456",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "${uuid}"
#vlessgrpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vless-grpc"
           }
        }
     },
     {
      "listen": "127.0.0.1",
     "port": "31234",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0
#vmessgrpc
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": {
                "serviceName": "vmess-grpc"
          }
        }
     },
     {
        "listen": "127.0.0.1",
     "port": "33456",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "${uuid}"
#trojangrpc
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": {
               "serviceName": "trojan-grpc"
         }
      }
   },
   {
    "listen": "127.0.0.1",
    "port": "30310",
    "protocol": "shadowsocks",
    "settings": {
        "clients": [
          {
             "method": "aes-256-gcm",
             "password": "${uuid}"
#ssgrpc
           }
         ],
           "network": "tcp,udp"
      },
    "streamSettings":{
     "network": "grpc",
        "grpcSettings": {
           "serviceName": "ss-grpc"
          }
       }
    }	
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
END
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service
cat <<EOF> /etc/systemd/system/xray.service
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Service
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

#nginx config
cat >/etc/nginx/conf.d/xray.conf <<EOF
    server {
             listen 80;
             listen [::]:80;
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             server_name $domain;
             ssl_certificate /etc/xray/xray.crt;
             ssl_certificate_key /etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /home/vps/public_html;
        }
EOF
sed -i '$ ilocation = /vless' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:14016;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:23456;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:25432;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /ss-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:30300;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:700;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:24456;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:31234;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:33456;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /ss-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:30310;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

echo -e "$yell[SERVICE]$NC Restart All service"
systemctl daemon-reload
sleep 1
echo -e "[ ${green}ok${NC} ] Enable & restart xray "
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn

cd /usr/bin/
# menu
wget -O menu "https://raw.githubusercontent.com/nanotechid/sv/script/menu/menu.sh"
wget -O m-vmess "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-vmess.sh"
wget -O m-vless "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-vless.sh"
wget -O running "https://raw.githubusercontent.com/nanotechid/sv/script/menu/running.sh"
wget -O clearcache "https://raw.githubusercontent.com/nanotechid/sv/script/menu/clearcache.sh"
wget -O m-ssws "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-ssws.sh"
wget -O m-trojan "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-trojan.sh"

# menu system
wget -O m-system "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-system.sh"
wget -O m-domain "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-domain.sh"
wget -O add-host "https://raw.githubusercontent.com/nanotechid/sv/script/ssh/add-host.sh"
wget -O certv2ray "https://raw.githubusercontent.com/nanotechid/sv/script/xray/certv2ray.sh"
wget -O m-webmin "https://raw.githubusercontent.com/nanotechid/sv/script/menu/m-webmin.sh"
wget -O speedtest "https://raw.githubusercontent.com/nanotechid/sv/script/ssh/speedtest_cli.py"
wget -O auto-reboot "https://raw.githubusercontent.com/nanotechid/sv/script/menu/auto-reboot.sh"
wget -O restart "https://raw.githubusercontent.com/nanotechid/sv/script/menu/restart.sh"
wget -O bw "https://raw.githubusercontent.com/nanotechid/sv/script/menu/bw.sh"

# vmess
wget -O add-ws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vmess/add-ws.sh" && chmod +x add-ws
wget -O trialvmess "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vmess/trialvmess.sh" && chmod +x trialvmess
wget -O renew-ws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vmess/renew-ws.sh" && chmod +x renew-ws
wget -O del-ws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vmess/del-ws.sh" && chmod +x del-ws
wget -O cek-ws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vmess/cek-ws.sh" && chmod +x cek-ws

# vless
wget -O add-vless "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vless/add-vless.sh" && chmod +x add-vless
wget -O trialvless "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vless/trialvless.sh" && chmod +x trialvless
wget -O renew-vless "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vless/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vless/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/nanotechid/sv/script/xray/vless/cek-vless.sh" && chmod +x cek-vless

# trojan
wget -O add-tr "https://raw.githubusercontent.com/nanotechid/sv/script/xray/trojan/add-tr.sh" && chmod +x add-tr
wget -O trialtrojan "https://raw.githubusercontent.com/nanotechid/sv/script/xray/trojan/trialtrojan.sh" && chmod +x trialtrojan
wget -O del-tr "https://raw.githubusercontent.com/nanotechid/sv/script/xray/trojan/del-tr.sh" && chmod +x del-tr
wget -O renew-tr "https://raw.githubusercontent.com/nanotechid/sv/script/xray/trojan/renew-tr.sh" && chmod +x renew-tr
wget -O cek-tr "https://raw.githubusercontent.com/nanotechid/sv/script/xray/trojan/cek-tr.sh" && chmod +x cek-tr

# shadowsocks
wget -O add-ssws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/ss/add-ssws.sh" && chmod +x add-ssws
wget -O trialssws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/ss/trialssws.sh" && chmod +x trialssws
wget -O del-ssws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/ss/del-ssws.sh" && chmod +x del-ssws
wget -O renew-ssws "https://raw.githubusercontent.com/nanotechid/sv/script/xray/ss/renew-ssws.sh" && chmod +x renew-ssws


sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"

mv /root/domain /etc/xray/ 
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
rm -f ins-xray.sh  
