#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-uqm"
archrgs_module_desc="The Ur-Quan Masters (Port of DOS game Star Control 2)"
archrgs_module_licence="GPL2 https://sourceforge.net/p/sc2/uqm/ci/v0.7.0-1/tree/sc2/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-uqm() {
    pacmanPkg rgs-pt-uqm
}

function remove_rgs-pt-uqm() {
    pacmanRemove rgs-pt-uqm
}

function configure_rgs-pt-uqm() {
    moveConfigDir "$home/.uqm" "$md_conf_root/uqm"
    
    addPort "$md_id" "uqm" "Ur-Quan Masters" "$md_inst/bin/uqm --fullscreen --opengl --contentdir=$md_inst/content --addondir=$md_inst/content"
}
