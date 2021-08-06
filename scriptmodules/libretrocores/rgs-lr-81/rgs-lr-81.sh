#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-81"
archrgs_module_desc="Sinclair ZX81 Libretro Core"
archrgs_module_help="ROM Extensions: .p .tzx .t81\n\nCopy Your ZX81 ROMs to $romdir/zx81"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/81-libretro/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-81() {
  pacmanPkg rgs-lr-81
}

function remove_rgs-lr-81() {
  pacmanRemove rgs-lr-81
}

function configure_rgs-lr-81() {
  mkRomDir "zx81"
  
  ensureSystemretroconfig "zx81"
  
  addEmulator 1 "$md_id" "zx81" "$md_inst/81_libretro.so"
  addSystem "zx81"
 }
 
