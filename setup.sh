#!/bin/bash

clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd /root
#System version number
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi

mkdir -p /etc/xray
mkdir -p /etc/v2ray
touch /etc/xray/domain
touch /etc/v2ray/domain
touch /etc/xray/scdomain
touch /etc/v2ray/scdomain

ttet=`uname -r`
ReqPKG="linux-headers-$ttet"
if ! dpkg -s $ReqPKG  >/dev/null 2>&1; then
  rm /root/setup.sh >/dev/null 2>&1 
  exit
else
  clear
fi

secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
END
chmod 644 /root/.profile

mkdir -p /var/lib >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf
clear
yellow "Tambah domain anda untuk issue cert"
yellow "Bahan yang diperlukan"
yellow "- Cloudflare Global Key"
yellow "- Cloudflare Email"
yellow "- Google Email"
yellow "- ID Key Google"
yellow "- Hmac Key Google"
echo " "
read -rp "Input DNS (contoh maps.google.com) : " -e dns
read -rp "Input Domain utama (contoh google.com, facebook.com) : " -e domain
read -rp "Cloudflare Key : " -e cfkey
read -rp "Cloudflare Email : " -e cfemail
read -rp "Google Email : " -e gmail
read -rp "ID Key Google : " -e keyid
read -rp "Hmac Key Google : " -e hmac
    if [ -z $dns ]; then
        echo -e "Nothing input for DNS!"
    else
    if [ -z $domain ]; then
        echo -e "Nothing input for Domain!"
    else
    if [ -z $cfkey ]; then
        echo -e "Nothing input for Cloudflare Key!"
    else
    if [ -z $cfemail ]; then
        echo -e "Nothing input for Cloudflare Email!"
    else
    if [ -z $gmail ]; then
        echo -e "Nothing input for Google Email!"
    else
    if [ -z $keyid ]; then
        echo -e "Nothing input for Key ID Google!"
    else
    if [ -z $hmac ]; then
        echo -e "Nothing input for Hmac Key Google!"
    else
        echo "$domain" > /root/scdomain
	echo "$domain" > /etc/xray/scdomain
	echo "$domain" > /etc/xray/domain
	echo "$domain" > /etc/v2ray/domain
	echo "$domain" > /root/domain
  echo "IP=$domain" > /var/lib/ipvps.conf
  echo "$dns" > /root/dns
  echo "$cfkey" > /etc/cfkey
  echo "$cfemail" > /etc/cfemail
  echo "$gmail" > /etc/gmail
  echo "$keyid" > /etc/keyid
        echo "$hmac" > /etc/hmac
    fi
    fi
    fi
    fi
    fi
    fi
    fi

#Instal Xray
echo -e "\e[33m?????????????????????????????????????????????????????????????????????????????????????????????????????????\033[0m"
echo -e "$green          Install XRAY              $NC"
echo -e "\e[33m?????????????????????????????????????????????????????????????????????????????????????????????????????????\033[0m"
sleep 2
clear
wget https://raw.githubusercontent.com/nanotechid/sv/script/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi

curl -sS ifconfig.me > /etc/myipvps
echo " "
echo "------------------------------------------------------------"
echo ""
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - Nginx		: 81" | tee -a log-install.txt
echo "   - Vmess TLS		: 443" | tee -a log-install.txt
echo "   - Vmess None TLS	: 80" | tee -a log-install.txt
echo "   - Vless TLS		: 443" | tee -a log-install.txt
echo "   - Vless None TLS	: 80" | tee -a log-install.txt
echo "   - Trojan GRPC		: 443" | tee -a log-install.txt
echo "   - Trojan WS		: 443" | tee -a log-install.txt
echo "   - Trojan XTLS		: 443" | tee -a log-install.txt
echo "   - Shadowsocks WS       : 443" | tee -a log-install.txt
echo "   - Shadowsocks GRPC     : 443" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""
echo "------------------------------------------------------------"
echo -e ""
echo ""
echo "" | tee -a log-install.txt
rm /root/setup.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
echo -e "
"
echo -ne "[ ${yell}WARNING${NC} ] reboot now ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi





