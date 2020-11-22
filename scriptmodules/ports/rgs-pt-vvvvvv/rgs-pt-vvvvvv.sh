#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-vvvvvv"
archrgs_module_desc="VVVVVV - 2D Puzzle Game"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md"
archrgs_module_help="Copy data.zip from a purchased or Make and Play edition of VVVVVV to $romdir/ports/vvvvvv"
archrgs_module_section="ports"

function install_bin_rgs-pt-vvvvvv() {
  pacmanPkg rgs-pt-vvvvvv
}

function remove_rgs-pt-vvvvvv() {
  pacmanRemove rgs-pt-vvvvvv
}

function configure_rgs-pt-vvvvvv() {
  addPort "$md_id" "vvvvvv" "VVVVVV" "$md_inst/bin/VVVVVV"

  [[ "$md_mode" != "install" ]] && return

  moveConfigDir "$home/.local/share/VVVVVV" "$md_conf_root/vvvvvv"

  mkUserDir "$romdir/ports/vvvvvv"

  ## Symlink Game Data
  ln -snf "$romdir/ports/vvvvvv/data.zip" "$md_inst/bin/data.zip"
}

