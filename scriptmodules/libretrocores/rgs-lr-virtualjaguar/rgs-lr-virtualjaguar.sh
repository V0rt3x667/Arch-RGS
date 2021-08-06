#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-virtualjaguar"
archrgs_module_desc="Atari Jaguar Libretro Core"
archrgs_module_help="ROM Extensions: .j64 .jag .zip\n\nCopy Your Atari Jaguar ROMs to $romdir/atarijaguar"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/virtualjaguar-libretro/master/docs/GPLv3"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-virtualjaguar() {
  pacmanPkg rgs-lr-virtualjaguar
}

function remove_rgs-lr-virtualjaguar() {
  pacmanRemove rgs-lr-virtualjaguar
}

function configure_rgs-lr-virtualjaguar() {
  mkRomDir "atarijaguar"

  ensureSystemretroconfig "atarijaguar"

  addEmulator 1 "$md_id" "atarijaguar" "$md_inst/virtualjaguar_libretro.so"
  addSystem "atarijaguar"
}

