#!/usr/bin/with-contenv bash
# Tolga Erok
# 13 Jan 26
# install shellcheck and shfmt for vscode

if ! command -v shellcheck &>/dev/null; then
	apt-get update
	apt-get install -y shellcheck wget
fi

if ! command -v shfmt &>/dev/null; then
	wget -q https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_linux_amd64 -O /usr/local/bin/shfmt
	chmod +x /usr/local/bin/shfmt
fi

# Notes:
#    docker stop vscode && docker rm vscode && sudo systemctl restart docker-stack.service
