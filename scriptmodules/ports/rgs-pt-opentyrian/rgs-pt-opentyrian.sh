#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-opentyrian"
archrgs_module_desc="Open Tyrian - Port of the Classic DOS Game Tyrian"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/opentyrian/opentyrian/master/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-opentyrian() {
  pacmanPkg rgs-pt-opentyrian
}

function remove_rgs-pt-opentyrian() {
  pacmanRemove rgs-pt-opentyrian
}

function game_data_rgs-pt-opentyrian() {
  if [[ ! -d "$romdir/ports/opentyrian/data" ]]; then
    cd "$__tmpdir"
    ##Get Tyrian 2.1 (Freeware Game Data)
    downloadAndExtract "$__archive_url/tyrian21.zip" "$romdir/ports/opentyrian/data" -j
    chown -R "$user:$user" "$romdir/ports/opentyrian"
  fi
}

function configure_rgs-pt-opentyrian() {
  addPort "$md_id" "opentyrian" "OpenTyrian" "$md_inst/bin/opentyrian --data $romdir/ports/opentyrian/data"

  mkRomDir "ports/opentyrian"

  moveConfigDir "$home/.config/opentyrian" "$md_conf_root/opentyrian"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-opentyrian
}

