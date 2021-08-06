#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-yabause"
archrgs_module_desc="Sega Saturn Libretro Core"
archrgs_module_help="ROM Extensions: .iso .bin .zip\n\nCopy Your Sega Saturn ROMs to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/master/yabause/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-yabause() {
  pacmanPkg rgs-lr-yabause
}

function remove_rgs-lr-yabause() {
  pacmanRemove rgs-lr-yabause
}

function configure_rgs-lr-yabause() {
  mkRomDir "saturn"

  ensureSystemretroconfig "saturn"

  addEmulator 1 "$md_id" "saturn" "$md_inst/yabause_libretro.so"
  addSystem "saturn"
}

