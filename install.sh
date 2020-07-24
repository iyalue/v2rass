#!/bin/bash
wget https://install.direct/go.sh
bash go.sh
cp /etc/v2ray/config.json /etc/v2ray/config.json.bakup
cat <<EOF >/etc/v2ray/config.json
{
  "inbounds": [
    {
      "port": 10000,
      "listen":"127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "9bcc9807-536a-4eb8-ae02-16ccb91f035e",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/yanghang"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

read -p "Plese input the domain of your website:" domain
if [ -w /etc/caddy/Caddyfile ];then
cat <<EOF >etc/caddy/Caddyfile
$domain {
    log {
        output file /etc/caddy/caddy.log
    }
    tls {
        protocols tls1.2 tls1.3
        ciphers TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        curves x25519
    }
    @v2ray_websocket {
        path /yanghang
        header Connection *Upgrade*
        header Upgrade websocket
    }
    reverse_proxy @v2ray_websocket localhost:10000
}
EOF
else
    echo "there is no this file"
fi

systemctl restart caddy
systemctl start v2ray
exit 0
