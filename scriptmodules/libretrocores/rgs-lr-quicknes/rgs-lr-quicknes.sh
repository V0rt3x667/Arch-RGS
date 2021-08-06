#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-quicknes"
archrgs_module_desc="Nintendo Entertainment System Libretro Core"
archrgs_module_help="ROM Extensions: .nes .zip\n\nCopy Your NES ROMs to $romdir/nes"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/QuickNES_Core/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-quicknes() {
  pacmanPkg rgs-lr-quicknes
}

function remove_rgs-lr-quicknes() {
  pacmanRemove rgs-lr-quicknes
}

function configure_rgs-lr-quicknes() {
  mkRomDir "nes"

  ensureSystemretroconfig "nes"

  addEmulator 0 "$md_id" "nes" "$md_inst/quicknes_libretro.so"
  addSystem "nes"
}

