#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-2048"
archrgs_module_desc="2048 Libretro Core"
archrgs_module_help="https://github.com/libretro/libretro-2048"
archrgs_module_licence="The Unlicense https://raw.githubusercontent.com/libretro/libretro-2048/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-2048() {
  pacmanPkg rgs-lr-2048
}

function remove_rgs-lr-2048() {
  pacmanRemove rgs-lr-2048
}

function configure_rgs-lr-2048() {
  setConfigRoot "ports"
  
  addPort "$md_id" "2048" "2048" "$md_inst/2048_libretro.so"
  
  ensureSystemretroconfig "ports/2048"
}

