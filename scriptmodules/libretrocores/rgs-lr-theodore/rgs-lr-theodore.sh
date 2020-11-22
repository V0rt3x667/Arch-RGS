#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-theodore"
archrgs_module_desc="Thomson TO7, TO7/70, TO8, TO8D, TO9, TO9+, MO5 & MO6 Libretro Core"
archrgs_module_help="ROM Extensions: *.fd, *.sap, *.k7, *.m5, *.m7, *.rom\n\nAdd your game files in $romdir/moto"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/theodore/master/LICENSE"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-theodore() {
  pacmanPkg rgs-lr-theodore
}

function remove_rgs-lr-theodore() {
  pacmanRemove rgs-lr-theodore
}

function configure_rgs-lr-theodore() {
  mkRomDir "moto"

  ensureSystemretroconfig "moto"

  addEmulator 1 "$md_id" "moto" "$md_inst/theodore_libretro.so"
  addSystem "moto"
}

