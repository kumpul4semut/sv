

- SSH Websocket TLS : 443
- SSH Websocket none TLS : 80
- Vmess WS+TLS : 443
- Vmess gRPC+TLS : 443
- Vless WS+TLS : 444
- Vless gRPC+TLS : 443
- 

```
apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget https://raw.githubusercontent.com/nanotechid/sv/script/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh
```
