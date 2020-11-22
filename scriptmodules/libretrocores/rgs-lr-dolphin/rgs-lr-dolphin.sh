#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-dolphin"
archrgs_module_desc="Nintendo Gamecube & Wii Libretro Core"
archrgs_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz\n\nCopy your gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-dolphin() {
  pacmanPkg rgs-lr-dolphin
}

function remove_rgs-lr-dolphin() {
  pacmanRemove rgs-lr-dolphin
}

function configure_rgs-lr-dolphin() {
  mkRomDir "gc"
  mkRomDir "wii"

  ensureSystemretroconfig "gc"
  ensureSystemretroconfig "wii"

  addEmulator 1 "$md_id" "gc" "$md_inst/dolphin_libretro.so"
  addEmulator 1 "$md_id" "wii" "$md_inst/dolphin_libretro.so"

  addSystem "gc"
  addSystem "wii"
}

