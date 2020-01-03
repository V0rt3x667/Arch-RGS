#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-supermariowar"
archrgs_module_desc="Super Mario War"
archrgs_module_licence="GPL http://supermariowar.supersanctuary.net/"
archrgs_module_section="ports"

function install_bin_rgs-pt-supermariowar() {
    pacmanPkg rgs-pt-supermariowar
}

function remove_rgs-pt-supermariowar() {
    pacmanRemove rgs-pt-supermariowar
}

function configure_rgs-pt-supermariowar() {
    addPort "$md_id" "supermariowar" "Super Mario War" "$md_inst/smw $md_inst/data"

    moveConfigDir "$home/.smw" "$md_conf_root/supermariowar"
}
