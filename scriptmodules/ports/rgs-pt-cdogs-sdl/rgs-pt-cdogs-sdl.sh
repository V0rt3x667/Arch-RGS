#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-cdogs-sdl"
archrgs_module_desc="C-Dogs SDL - Classic Overhead Run-and-Gun Game"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/cxong/cdogs-sdl/master/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-cdogs-sdl() {
  pacmanPkg rgs-pt-cdogs-sdl
}

function remove_rgs-pt-cdogs-sdl() {
  pacmanRemove rgs-pt-cdogs-sdl
}

function configure_rgs-pt-cdogs-sdl() {
  moveConfigDir "$home/.config/cdogs-sdl" "$md_conf_root/cdogs-sdl"

  addPort "$md_id" "cdogs-sdl" "C-Dogs SDL" "pushd $md_inst; $md_inst/cdogs-sdl --fullscreen; popd"
}
