#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-cgenius"
archrgs_module_desc="Commander Genius - Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
archrgs_module_section="ports"

function install_bin_rgs-pt-cgenius() {
  pacmanPkg rgs-pt-cgenius
}

function remove_rgs-pt-cgenius() {
  pacmanRemove rgs-pt-cgenius
}

function configure_rgs-pt-cgenius() {
  addPort "$md_id" "cgenius" "Commander Genius" "$md_inst/bin/CGeniusExe dir=%ROM%"

  mkRomDir "ports/cgenius"

  moveConfigDir "$home/.CommanderGenius" "$md_conf_root/cgenius"
  moveConfigDir "$md_conf_root/cgenius/games" "$romdir/ports/cgenius"
}
