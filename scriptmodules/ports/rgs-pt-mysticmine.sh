#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-mysticmine"
archrgs_module_desc="Mystic Mine - Rail game for up to six players on one keyboard"
archrgs_module_licence="MIT https://raw.githubusercontent.com/dewitters/MysticMine/master/LICENSE.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-mysticmine() {
    pacmanPkg rgs-pt-mysticmine
}

function remove_rgs-pt-mysticmine() {
    pacmanRemove rgs-pt-mysticmine
}

function configure_rgs-pt-mysticmine() {
    addPort "$md_id" "mysticmine" "MysticMine" "pushd $md_inst; PYTHONPATH=$PYTHONPATH:${md_inst}/lib/python2.7/site-packages ./bin/MysticMine; popd"
}