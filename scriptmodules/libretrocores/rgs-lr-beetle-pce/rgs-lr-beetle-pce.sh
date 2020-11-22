#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-pce"
archrgs_module_desc="NEC PC Engine (TurboGrafx-16) & PC Engine SuperGrafx Libretro Core"
archrgs_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopy your PC Engine / TurboGrafx roms to $romdir/pcengine\n\nCopy the required BIOS file syscard3.pce to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pce-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-pce() {
  pacmanPkg rgs-lr-beetle-pce
}

function remove_rgs-lr-beetle-pce() {
  pacmanRemove rgs-lr-beetle-pce
}

function configure_rgs-lr-beetle-pce() {
  mkRomDir "pcengine"
  ensureSystemretroconfig "pcengine"

  addEmulator 1 "$md_id" "pcengine" "$md_inst/mednafen_pce_fast_libretro.so"
  addSystem "pcengine"
}

