#!/usr/bin/env bash

# Download and patch build.func to use custom install script repo
BUILD_FUNC=$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
BUILD_FUNC_PATCHED=$(echo "$BUILD_FUNC" | sed 's|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/${var_install}.sh|https://raw.githubusercontent.com/athena-sh/whisparr-v3-builds/main/whisparr-v3-install.sh|g')
source <(echo "$BUILD_FUNC_PATCHED")

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Co-Author: athena-sh
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Whisparr/Whisparr (eros branch)

APP="Whisparr-v3"
var_tags="${var_tags:-arr;whisparr;eros-branch;community-script}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-12}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /var/lib/whisparr ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  systemctl stop whisparr
  RELEASE=$(curl -s https://api.github.com/repos/athena-sh/whisparr-v3-builds/releases | grep -m 1 "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Updating ${APP} to ${RELEASE}"
    cd /opt
    rm -rf Whisparr
    wget -q https://github.com/athena-sh/whisparr-v3-builds/releases/download/${RELEASE}/Whisparr-v3-eros.tar.gz
    tar -xzf Whisparr-v3-eros.tar.gz
    echo "${RELEASE}" > /opt/${APP}_version.txt
    rm Whisparr-v3-eros.tar.gz
    msg_ok "Updated ${APP} to ${RELEASE}"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  systemctl start whisparr
  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6969${CL}
