#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-stella"
archrgs_module_desc="Atari 2600 Libretro Core"
archrgs_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy Your Atari 2600 ROMs to $romdir/atari2600"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/stella-libretro/master/stella/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-stella() {
  pacmanPkg rgs-lr-stella
}

function remove_rgs-lr-stella() {
  pacmanRemove rgs-lr-stella
}

function configure_rgs-lr-stella() {
  mkRomDir "atari2600"

  ensureSystemretroconfig "atari2600"

  addEmulator 1 "$md_id" "atari2600" "$md_inst/stella_libretro.so"
  addSystem "atari2600"
}

