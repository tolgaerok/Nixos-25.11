# Tolga Erok
# 12 Jan 26
# Version 6

╔═══════════════════════════════════════════╗
║                  localhost                ║
╚═══════════════════════════════════════════╝

VS Code:
https://localhost:8443  (master password)

# install shfmt into vscode docker
# pull official image
docker pull mvdan/shfmt:v3

# install shfmt binary into vscode container
docker exec -it vscode bash -c "
  curl -fsSL https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_linux_amd64 -o /usr/local/bin/shfmt && 
  chmod +x /usr/local/bin/shfmt
"

docker exec -it vscode bash -c "
  apt-get update && 
  apt-get install -y shellcheck wget && 
  wget https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_linux_amd64 -O /usr/local/bin/shfmt && 
  chmod +x /usr/local/bin/shfmt
"

# verify both work
docker exec -it vscode shellcheck --version
docker exec -it vscode shfmt --version
# verify it works
docker exec -it vscode shfmt --version

# Restart container: 
docker restart vscode

# further updates
docker exec -it debian-test bash

if ! command -v shellcheck &> /dev/null; then
    apt-get update
    apt-get install -y shellcheck wget
fi

if ! command -v shfmt &> /dev/null; then
    wget -q https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_linux_amd64 -O /usr/local/bin/shfmt
    chmod +x /usr/local/bin/shfmt
fi


+ ============================================================================================================================ +

Portainer: http://localhost:9000
Restart portainer: docker restart portainer

+ ============================================================================================================================ +

Grafana:
http://localhost:3000
(default: admin/admin, forces password change)

+ ============================================================================================================================ +

Prometheus:
http://localhost:9090

+ ============================================================================================================================ +


╔═══════════════════════════════════════════╗
║              docker containers            ║
╚═══════════════════════════════════════════╝
# check containers running
docker ps

# enter any container
docker exec -it debian-test bash
docker exec -it fedora-test bash
docker exec -it arch-test bash

# or run scripts directly within
docker exec debian-test bash /home/tolga/docker-stack/scripts/linuxtweaks.sh


╔═══════════════════════════════════════════╗
║              Trouble shooting             ║
╚═══════════════════════════════════════════╝
# Nuke them completely:
sudo docker stop $(sudo docker ps -aq) 2>/dev/null
sudo docker rm $(sudo docker ps -aq) 2>/dev/null
sudo docker system prune -af --volumes

# restart the service:
sudo systemctl restart docker-stack.service
sudo journalctl -u docker-stack.service -f
sudo systemctl status docker-stack.service --no-pager


enjoy
