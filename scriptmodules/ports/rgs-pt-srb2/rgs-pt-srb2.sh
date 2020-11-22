#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-srb2"
archrgs_module_desc="Sonic Robo Blast 2 - 3D Sonic the Hedgehog Fangame"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/STJr/SRB2/master/LICENSE"
archrgs_module_section="ports"

function install_bin_rgs-pt-srb2() {
  pacmanPkg rgs-pt-srb2
}

function remove_rgs-pt-srb2() {
  pacmanRemove rgs-pt-srb2
}

function configure_rgs-pt-srb2() {
  addPort "$md_id" "srb2" "Sonic Robo Blast 2" "pushd $md_inst; ./lsdlsrb2; popd"

  moveConfigDir "$home/.srb2"  "$md_conf_root/$md_id"
}

