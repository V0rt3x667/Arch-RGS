#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-gzdoom"
archrgs_module_desc="GZDoom - Enhanced DOOM Port"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/coelckers/gzdoom/master/LICENSE"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-gzdoom() {
  pacmanPkg rgs-pt-gzdoom
}

function remove_rgs-pt-gzdoom() {
  pacmanRemove rgs-pt-gzdoom
}

function add_games_rgs-pt-gzdoom() {
  local launcher_prefix

  launcher_prefix="DOOMWADDIR=$romdir/ports/doom"

  _add_games_rgs-lr-prboom "$launcher_prefix $md_inst/bin/gzdoom -iwad %ROM% +fullscreen 1"
}

function configure_rgs-pt-gzdoom() {
  mkRomDir "ports/doom"

  moveConfigDir "$home/.config/gzdoom" "$md_conf_root/doom"

  [[ "$md_mode" == "install" ]] && game_data_rgs-lr-prboom

  add_games_rgs-pt-gzdoom
}

