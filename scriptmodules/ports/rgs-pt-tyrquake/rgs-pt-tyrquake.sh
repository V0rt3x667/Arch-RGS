#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-tyrquake"
archrgs_module_desc="TyrQuake - Quake I Port"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/tyrquake/master/gnu.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-tyrquake() {
  pacmanPkg rgs-pt-tyrquake
}

function remove_rgs-pt-tyrquake() {
  pacmanRemove rgs-pt-tyrquake
}

function add_games_rgs-pt-tyrquake() {
  _add_games_rgs-lr-tyrquake "$md_inst/bin/tyr-glquake -f -basedir $romdir/ports/quake -game %QUAKEDIR%"
}

function configure_rgs-pt-tyrquake() {
  mkRomDir "ports/quake"

  [[ "$md_mode" == "install" ]] && game_data_rgs-lr-tyrquake

  add_games_rgs-pt-tyrquake

  moveConfigDir "$home/.tyrquake" "$md_conf_root/quake/tyrquake"
}

