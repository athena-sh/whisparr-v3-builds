#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Co-Author: athena-sh
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Whisparr/Whisparr (eros branch)

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y sqlite3
msg_ok "Installed Dependencies"

msg_info "Installing Whisparr v3 (Eros)"
mkdir -p /var/lib/whisparr/
chmod 775 /var/lib/whisparr/

# Download pre-compiled Whisparr v3 from GitHub releases
cd /opt || exit
RELEASE=$(curl -s https://api.github.com/repos/athena-sh/whisparr-v3-builds/releases | grep -m 1 "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
msg_info "Downloading Whisparr v3 ${RELEASE}"
$STD curl -fsSL "https://github.com/athena-sh/whisparr-v3-builds/releases/download/${RELEASE}/Whisparr-v3-eros.tar.gz" -o Whisparr-v3-eros.tar.gz
$STD tar -xzf Whisparr-v3-eros.tar.gz
chmod 775 /opt/Whisparr
rm -f Whisparr-v3-eros.tar.gz
echo "${RELEASE}" > /opt/Whisparr-v3_version.txt
msg_ok "Installed Whisparr v3 (Eros) ${RELEASE}"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/whisparr.service
[Unit]
Description=Whisparr v3 (Eros) Daemon
After=network.target

[Service]
User=whisparr
Group=whisparr
Type=simple
ExecStart=/opt/Whisparr/Whisparr -nobrowser -data=/var/lib/whisparr
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

msg_info "Creating Service User"
useradd --system --no-create-home --shell /usr/sbin/nologin whisparr
chown -R whisparr:whisparr /var/lib/whisparr
chown -R whisparr:whisparr /opt/Whisparr
msg_ok "Created Service User"

systemctl enable --now -q whisparr
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
