domain=$(cat /etc/xray/domain)
dns=$(cat /root/dns)
tls="$(cat ~/log-install.txt | grep -w "Shadowsocks WS" | cut -d: -f2|sed 's/ //g')"
tls2="$(cat ~/log-install.txt | grep -w "Shadowsocks GRPC" | cut -d: -f2|sed 's/ //g')"
user=trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
cipher="2022-blake3-aes-256-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
ss22=$(openssl rand -base64 32)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#ssws$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#ssgrpc$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
echo $cipher:$uuid > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
echo -n "${shadowsocks_base64}" | base64 > /tmp/log1
shadowsocks_base64e=$(cat /tmp/log1)
shadowsockslink="ss://${shadowsocks_base64e}@isi_bug_disini:$tls?path=ss-ws&security=tls&host=${dns}&type=ws&sni=${dns}#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@${dns}:$tls2?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m        Trial Shadowsocks     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks      : ${user}"
echo -e "Domain       : ${dns}"
echo -e "Wildcard     : [bug.com].${dns}"
echo -e "Port TLS 	  : ${tls}"
echo -e "Port GRPC    : ${tls2}"
echo -e "Password 	  : ${ss22}"
echo -e "Cipher		    : ${cipher}"
echo -e "Network	    : ws/grpc"
echo -e "Path 		    : /ss-ws"
echo -e "ServiceName 	: ss-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link WS  	  : ${shadowsockslink}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC 	  : ${shadowsockslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
#echo -e "Link JSON  	: http://${domain}/ss-$user.txt"
#echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On   : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "" | tee -a /etc/log-create-user.log
read -n 1 -s -r -p "Press any key to back on menu"
menu
