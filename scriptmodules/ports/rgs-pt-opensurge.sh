#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-opensurge"
archrgs_module_desc="Open Surge - A fun 2D retro platformer inspired by Sonic games and a game creation system)"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/alemart/opensurge/master/LICENSE"
archrgs_module_section="ports"

function install_bin_rgs-pt-opensurge() {
    pacmanPkg rgs-pt-opensurge
}

function remove_rgs-pt-opensurge() {
    pacmanRemove rgs-pt-opensurge
}

function configure_rgs-pt-opensurge() {
    addPort "$md_id" "opensurge" "Open Surge" "$md_inst/bin/opensurge --fullscreen"

    moveConfigDir "$home/.config/opensurge2d"  "$md_conf_root/opensurge"
}
