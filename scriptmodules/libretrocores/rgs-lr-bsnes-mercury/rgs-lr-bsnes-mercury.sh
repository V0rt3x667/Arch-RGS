#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-bsnes-mercury"
archrgs_module_desc="Super Nintendo Entertainment System Libretro Core"
archrgs_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes-mercury/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-bsnes-mercury() {
  pacmanPkg rgs-lr-bsnes-mercury
}

function remove_rgs-lr-bsnes-mercury() {
  pacmanRemove rgs-lr-bsnes-mercury
}

function configure_rgs-lr-bsnes-mercury() {
  mkRomDir "snes"
  
  ensureSystemretroconfig "snes"

  addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_accuracy_libretro.so"
  addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_balanced_libretro.so"
  addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_performance_libretro.so"
  
  addSystem "snes"
}

