#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-tgbdual"
archrgs_module_desc="Nintendo Gameboy & Gameboy Color Libretro Core"
archrgs_module_help="ROM Extensions: .gb .gbc .zip\n\nCopy Your GameBoy ROMs to $romdir/gb\n\nCopy Your GameBoy Color ROMs to $romdir/gbc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tgbdual-libretro/master/docs/COPYING-2.0.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-tgbdual() {
  pacmanPkg rgs-lr-tgbdual
}

function remove_rgs-lr-tgbdual() {
  pacmanRemove rgs-lr-tgbdual
}

function configure_rgs-lr-tgbdual() {
  mkRomDir "gbc"
  mkRomDir "gb"

  ensureSystemretroconfig "gb"
  ensureSystemretroconfig "gbc"

  ##Enable dual link by default
  setRetroArchCoreOption "tgbdual_gblink_enable" "enabled"

  addEmulator 0 "$md_id" "gb" "$md_inst/tgbdual_libretro.so"
  addEmulator 0 "$md_id" "gbc" "$md_inst/tgbdual_libretro.so"
  addSystem "gb"
  addSystem "gbc"
}

