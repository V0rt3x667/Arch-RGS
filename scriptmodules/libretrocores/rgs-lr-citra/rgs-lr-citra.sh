#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-citra"
archrgs_module_desc="Nintendo 3DS Libretro Core"
archrgs_module_help="ROM Extensions: .3ds .3dsx .app .cci .cxi\n\nCopy your Nintendo 3DS roms to $romdir/3ds"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra/master/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-citra() {
  pacmanPkg rgs-lr-citra
}

function remove_rgs-lr-citra() {
  pacmanRemove rgs-lr-citra
}

function configure_rgs-lr-citra() {
  mkRomDir "3ds"

  ensureSystemretroconfig "3ds"

  addEmulator 0 "$md_id" "3ds" "$md_inst/citra_libretro.so"
  addSystem "3ds"
}

