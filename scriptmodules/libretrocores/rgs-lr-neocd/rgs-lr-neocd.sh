#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-neocd"
archrgs_module_desc="Neo Geo CD Libretro Core"
archrgs_module_help="ROM Extension: .chd .cue\n\nCopy Your ROMs to\n$romdir/neogeo\n\nYou will need a minimum of two BIOS files (eg. ng-lo.rom, uni-bioscd.rom) which should be copied to $biosdir/neocd"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/neocd_libretro/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-neocd() {
  pacmanPkg rgs-lr-neocd
}

function remove_rgs-lr-neocd() {
  pacmanRemove rgs-lr-neocd
}

function configure_rgs-lr-neocd() {
  mkRomDir "neogeo"
  ensureSystemretroconfig "neogeo"

  addEmulator 0 "$md_id" "neogeo" "$md_inst/neocd_libretro.so"
  addSystem "neogeo"
}

