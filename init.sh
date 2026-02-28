#!/bin/bash
clear
echo "=================================================================="
echo "开始部署 [作品集建站 + VPN代理] 终极隔离环境..."
echo "=================================================================="

# 1. 更新系统并安装基础组件
apt-get update -y && apt-get install -y curl wget git vim ufw sudo

# 2. 开启系统原生 BBR 加速
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 3. 安装 Docker (所有服务的基石)
echo "正在安装 Docker..."
curl -fsSL https://get.docker.com | bash -s docker
systemctl enable docker
systemctl start docker

# 4. 部署 3x-ui 代理面板 (运行在后台)
echo "正在部署 3x-ui 代理面板..."
mkdir -p /opt/3x-ui && cd /opt/3x-ui
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
docker compose up -d
echo "3x-ui 部署成功！稍后访问 http://你的IP:2053 (账号 admin / 密码 admin)"

# 5. 安装 1Panel 现代化建站管理面板
echo "=================================================================="
echo "即将开始安装 1Panel 建站面板..."
echo "注意：安装过程中，系统会提示你设置【面板端口】、【账号】和【密码】"
echo "请务必记住你设置的信息！"
echo "=================================================================="
sleep 3
curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh

echo "=================================================================="
echo "🎉 全套环境部署完毕！"
echo "=================================================================="
