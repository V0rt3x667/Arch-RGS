#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution and
# at https://github.com/V0rt3x667/Arch-RetroGamingSystem/blob/master/LICENSE

archrgs_module_id="virtualgamepad"
archrgs_module_desc="Virtual Gamepad for Smartphone"
archrgs_module_licence="MIT https://raw.githubusercontent.com/miroof/node-virtual-gamepads/master/LICENSE"
archrgs_module_section="driver"
archrgs_module_flags="noinstclean"

function depends_virtualgamepad() {
    local depends=(
                  nodejs 
                  curl
                  )    
    getDepends "${depends[@]}"
}

function remove_virtualgamepad() {
    pm2 stop main
    pm2 delete main
}

function sources_virtualgamepad() {
    gitPullOrClone "$md_inst" https://github.com/miroof/node-virtual-gamepads.git
    chown -R $user:$user "$md_inst"
}

function install_virtualgamepad() {
    npm install pm2 -g --unsafe-perm
    cd "$md_inst"
    sudo -u $user npm install
    sudo -u $user npm install ref
}

function configure_virtualgamepad() {
    [[ "$md_mode" == "remove" ]] && return
    pm2 start main.js
    pm2 startup
    pm2 save
}
