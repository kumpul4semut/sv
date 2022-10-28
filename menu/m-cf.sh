#!/bin/bash

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo " Menu ini dibuat untuk anda yang lupa input CF KEY & EMAIL"
read -rp "CF KEY Anda: " -e cfkey
read -rp "CF EMAIL Anda: " -e cfemail
echo ""
if [ -z $cfkey ]; then
if [ -z $cfemail ]; then
  echo "$cfkey" > /etc/cfkey
  echo "$cfemail" > /etc/cfemail
echo "????"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
menu
else
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Dont forget to renew cert"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
fi
fi
