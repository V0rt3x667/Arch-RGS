#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-srb2kart"
archrgs_module_desc="Sonic Robo Blast 2 Kart - 3D Sonic the Hedgehog fan-game based on Sonic Robo Blast 2 built using a modified version of the Doom Legacy source port of Doom"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/STJr/Kart-Public/master/LICENSE"
archrgs_module_section="ports"

function install_bin_rgs-pt-srb2kart() {
    pacmanPkg rgs-pt-srb2kart
}

function remove_rgs-pt-srb2kart() {
    pacmanRemove rgs-pt-srb2kart
}

function configure_rgs-pt-srb2kart() {
    addPort "$md_id" "srb2kart" "Sonic Robo Blast 2 Kart" "pushd $md_inst; ./srb2kart; popd"
    moveConfigDir "$home/.srb2kart"  "$md_conf_root/$md_id"
}