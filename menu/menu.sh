#!/bin/bash
MYIP=$(curl -sS ipv4.icanhazip.com)
echo "Checking VPS"
#########################
IZIN=$(curl -sS https://raw.githubusercontent.com/nanotechid/sv/script/rex/vps | awk '{print $4}' | grep $MYIP)
if [ $MYIP = $IZIN ]; then
echo -e "\e[32mPermission Accepted...\e[0m"
else
echo -e "\e[31mPermission Denied!\e[0m";
exit 0
fi
#EXPIRED
expired=$(curl -sS https://raw.githubusercontent.com/nanotechid/sv/script/rex/vps | grep $MYIP | awk '{print $3}')
echo $expired > /root/expired.txt
today=$(date -d +1day +%Y-%m-%d)
while read expired
do
	exp=$(echo $expired | curl -sS https://raw.githubusercontent.com/nanotechid/sv/script/rex/vps | grep $MYIP | awk '{print $3}')
	if [[ $exp < $today ]]; then
		Exp2="\033[1;31mExpired\033[0m"
        else
        Exp2=$(curl -sS https://raw.githubusercontent.com/nanotechid/sv/script/rex/vps | grep $MYIP | awk '{print $3}')
	fi
done < /root/expired.txt
rm /root/expired.txt
Name=$(curl -sS https://raw.githubusercontent.com/nanotechid/sv/script/rex/vps | grep $MYIP | awk '{print $2}')
# Color Validation
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
# VPS Information
#Domain
domain=$(cat /etc/xray/domain)
#Status certificate
modifyTime=$(stat $HOME/.acme.sh/${domain}_ecc/${domain}.key | sed -n '7,6p' | awk '{print $2" "$3" "$4" "$5}')
modifyTime1=$(date +%s -d "${modifyTime}")
currentTime=$(date +%s)
stampDiff=$(expr ${currentTime} - ${modifyTime1})
days=$(expr ${stampDiff} / 86400)
remainingDays=$(expr 90 - ${days})
tlsStatus=${remainingDays}
if [[ ${remainingDays} -le 0 ]]; then
	tlsStatus="expired"
fi
# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"
# Getting CPU Information
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
DNS=$(cat /root/dns)
ISP=$(curl -s ipinfo.io/org?token=4c6f9da1e4484e)
CITY=$(curl -s ipinfo.io/city?token=4c6f9da1e4484e)
WKT=$(curl -s ipinfo.io/timezone?token=4c6f9da1e4484e)
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R)
IPVPS=$(curl -s ipinfo.io/ip?token=4c6f9da1e4484e)
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
uram=$( free -m | awk 'NR==2 {print $3}' )
fram=$( free -m | awk 'NR==2 {print $4}' )
clear
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[33m SYSTEM UPTIME \e[0m:  $uptime "
echo -e "\e[33m OS            \e[0m:  "`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`	
echo -e "\e[33m RAM           \e[0m:  $tram MB"
echo -e "\e[33m IP            \e[0m:  $IPVPS"	
echo -e "\e[33m ASN           \e[0m:  $ISP"
echo -e "\e[33m CITY          \e[0m:  $CITY"
echo -e "\e[33m DATE          \e[0m:  $DATE2"
echo -e "\e[33m DNS           \e[0m:  $DNS"	
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                 • MENU •                 "
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " [\e[36m•1\e[0m] SSH & OPENVPN MENU"
echo -e " [\e[36m•2\e[0m] VMESS MENU"
echo -e " [\e[36m•3\e[0m] VLESS MENU"
echo -e " [\e[36m•4\e[0m] SHADOWSOCKS MENU"
echo -e " [\e[36m•5\e[0m] TROJAN MENU"
echo -e " [\e[36m•6\e[0m] SYSTEM MENU"
echo -e " [\e[36m•7\e[0m] STATUS SERVICE"
echo -e " [\e[36m•8\e[0m] CHANGE TIMEZONE"
echo -e " [\e[36m•9\e[0m] CLEAR RAM CACHE"
echo -e   ""
echo -e   " PRESS x OR [ Ctrl+C ] • TO-EXIT-SCRIPT"
echo -e   ""
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[33mNAMA KLIEN	\E[0m: $Name"
echo -e " \e[33mEXPIRED 	\E[0m: $Exp2"
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e   ""
read -p " Select MENU :  "  opt
echo -e   ""
case $opt in
1) clear ; m-sshovpn ;;
2) clear ; m-vmess ;;
3) clear ; m-vless ;;
4) clear ; m-ssws ;;
5) clear ; m-trojan ;;
6) clear ; m-system ;;
7) clear ; running ;;
8) clear ; dpkg-reconfigure tzdata ;;
9) clear ; clearcache ;;
x) exit ;;
*) echo "Anda salah tekan " ; sleep 1 ; menu ;;
esac
