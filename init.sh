#!/bin/bash

echo "开始初始化服务器并部署基础环境..."

# 1. 更新系统并安装基础依赖 (适用于 Ubuntu/Debian)
apt-get update -y && apt-get upgrade -y
apt-get install -y curl wget git vim ufw software-properties-common

# 2. 开启系统原生 BBR 加速 (安全无痛，不换内核)
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 3. 官方脚本一键安装 Docker & Docker Compose
echo "正在安装 Docker 环境..."
curl -fsSL https://get.docker.com | bash -s docker
systemctl enable docker
systemctl start docker

# 4. 使用 Docker 部署 3x-ui (Xray/Trojan 代理面板)
echo "正在部署代理面板容器..."
mkdir -p /opt/3x-ui && cd /opt/3x-ui

# 自动生成 docker-compose.yml 配置文件
cat <<EOF > docker-compose.yml
services:
  3x-ui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3x-ui
    volumes:
      - ./db/:/etc/x-ui/
      - ./cert/:/root/cert/
    network_mode: host
    restart: unless-stopped
EOF

# 启动容器
docker compose up -d

echo "================================================="
echo "初始化完成！"
echo "BBR 已开启，Docker 已安装。"
echo "代理面板已在后台运行，默认端口为 2053"
echo "请在浏览器访问: http://你的VPS_IP:2053"
echo "默认账号: admin | 默认密码: admin"
echo "================================================="
