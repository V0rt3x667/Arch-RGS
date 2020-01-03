#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-bombermaaan"
archrgs_module_desc="Bombermaaan - Classic bomberman game"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/bjaraujo/Bombermaaan/master/LICENSE.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-bombermaaan() {
pacmanPkg rgs-pt-bombermaaan
}

function remove_rgs-pt-bombermaaan() {
pacmanRemove rgs-pt-bombermaaan
}

function configure_rgs-pt-bombermaaan() {
    moveConfigDir "$home/.Bombermaaan" "$md_conf_root/bombermaaan"
    
    addPort "$md_id" "bombermaaan" "Bombermaaan" "pushd $md_inst; $md_inst/bombermaaan; popd"
}
