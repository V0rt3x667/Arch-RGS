#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-saturn"
archrgs_module_desc="Sega Saturn Libretro Core"
archrgs_module_help="ROM Extensions: .cue\n\nCopy your Saturn roms to $romdir/saturn\n\nCopy the required BIOS files sega_101.bin / mpr-17933.bin to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-saturn-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-saturn() {
  pacmanPkg rgs-lr-beetle-saturn
}

function remove_rgs-lr-beetle-saturn() {
  pacmanRemove rgs-lr-beetle-saturn
}

function configure_rgs-lr-beetle-saturn() {
  mkRomDir "saturn"
  ensureSystemretroconfig "saturn"

  addEmulator 1 "$md_id" "saturn" "$md_inst/mednafen_saturn_libretro.so"
  addSystem "saturn"
}

