
- Support Wildcard : Yes ✅
- SSH Websocket TLS : 443
- SSH Websocket none TLS : 80
- Vmess WS+TLS : 443
- Vmess None TLS : 80
- Vmess gRPC+TLS : 443
- Vless WS+TLS : 443
- Vless None TLS : 80
- Vless gRPC+TLS : 443
- Trojan WS+TLS : 443
- Trojan gRPC+TLS : 443
- Shadowsocks WS+TLS : 443
- Shadowsocks gRPC+TLS : 443

```
apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget https://raw.githubusercontent.com/nanotechid/sv/script/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh
```
