#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-gw"
archrgs_module_desc="Nintendo Game & Watch Libretro Core"
archrgs_module_help="ROM Extension: .mgw\n\nCopy your Game and Watch games to $romdir/gameandwatch"
archrgs_module_licence="ZLIB https://raw.githubusercontent.com/libretro/gw-libretro/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-gw() {
  pacmanPkg rgs-lr-gw
}

function remove_rgs-lr-gw() {
  pacmanRemove rgs-lr-gw
}

function configure_rgs-lr-gw() {
  mkRomDir "gameandwatch"

  ensureSystemretroconfig "gameandwatch"

  addEmulator 1 "$md_id" "gameandwatch" "$md_inst/gw_libretro.so"
  addSystem "gameandwatch"
}

