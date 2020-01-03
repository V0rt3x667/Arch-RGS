#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-openttd"
archrgs_module_desc="Open Source Simulator Based On Transport Tycoon Deluxe"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/OpenTTD/OpenTTD/master/COPYING.md"
archrgs_module_section="ports"

function install_bin_rgs-pt-openttd() {
    pacmanPkg rgs-pt-openttd
}

function remove_rgs-pt-openttd() {
    pacmanRemove rgs-pt-openttd
}

function configure_rgs-pt-openttd() {
    local dir
    for dir in .config .local/share; do
        moveConfigDir "$home/$dir/openttd" "$md_conf_root/openttd"
    done

    moveConfigDir "$home/.local/openttd" "$md_conf_root/openttd"

    addPort "$md_id" "openttd" "OpenTTD" "$md_inst/bin/openttd"
}
