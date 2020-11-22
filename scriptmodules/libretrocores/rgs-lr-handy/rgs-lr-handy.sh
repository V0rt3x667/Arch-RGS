#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-handy"
archrgs_module_desc="Atari Lynx Libretro Core"
archrgs_module_help="ROM Extensions: .lnx .zip\n\nCopy your Atari Lynx roms to $romdir/atarilynx"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/libretro-handy/master/lynx/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-handy() {
  pacmanPkg rgs-lr-handy
}

function remove_rgs-lr-handy() {
  pacmanRemove rgs-lr-handy
}

function configure_rgs-lr-handy() {
  mkRomDir "atarilynx"

  ensureSystemretroconfig "atarilynx"

  addEmulator 1 "$md_id" "atarilynx" "$md_inst/handy_libretro.so"
  addSystem "atarilynx"
}

