#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-lynx"
archrgs_module_desc="Atari Lynx Libretro Core"
archrgs_module_help="ROM Extensions: .lnx .zip\n\nCopy your Atari Lynx roms to $romdir/atarilynx\n\nCopy the required BIOS file lynxboot.img to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-lynx-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-lynx() {
  pacmanPkg rgs-lr-beetle-lynx
}

function remove_rgs-lr-beetle-lynx() {
  pacmanRemove rgs-lr-beetle-lynx
}

function configure_rgs-lr-beetle-lynx() {
  mkRomDir "atarilynx"
  ensureSystemretroconfig "atarilynx"

  addEmulator 1 "$md_id" "atarilynx" "$md_inst/mednafen_lynx_libretro.so"
  addSystem "atarilynx"
}

