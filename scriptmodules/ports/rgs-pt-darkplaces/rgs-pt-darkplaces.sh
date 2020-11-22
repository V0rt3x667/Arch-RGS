#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-darkplaces"
archrgs_module_desc="Quake 1 - DarkPlaces Quake Engine"
archrgs_module_licence="GPL2 https://gitlab.com/xonotic/darkplaces/raw/div0-stable/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-darkplaces() {
  pacmanPkg rgs-pt-darkplaces
}

function remove_rgs-pt-darkplaces() {
  pacmanRemove rgs-pt-darkplaces
}

function add_games_rgs-pt-darkplaces() {
  _add_games_rgs-lr-tyrquake "$md_inst/bin/darkplaces-glx -basedir $romdir/ports/quake -game %QUAKEDIR%"
}

function configure_rgs-pt-darkplaces() {
  mkRomDir "ports/quake"

  [[ "$md_mode" == "install" ]] && game_data_rgs-lr-tyrquake

  add_games_rgs-pt-darkplaces

  moveConfigDir "$home/.darkplaces" "$md_conf_root/quake/darkplaces"
}

