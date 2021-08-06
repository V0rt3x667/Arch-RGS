#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-ngp"
archrgs_module_desc="Neo Geo Pocket & Pocket Color Libretro Core"
archrgs_module_help="ROM Extensions: .ngc .ngp .zip\n\nCopy Your Neo Geo Pocket ROMs to $romdir/ngp\n\nCopy Your Neo Geo Pocket Color ROMs to $romdir/ngpc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-ngp-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-ngp() {
  pacmanPkg rgs-lr-beetle-ngp
}

function remove_rgs-lr-beetle-ngp() {
  pacmanRemove rgs-lr-beetle-ngp
}

function configure_rgs-lr-beetle-ngp() {
  local system
  
  for system in ngp ngpc; do
      mkRomDir "$system"
      ensureSystemretroconfig "$system"
      addEmulator 1 "$md_id" "$system" "$md_inst/mednafen_ngp_libretro.so"
      addSystem "$system"
  done
}

