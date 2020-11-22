#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-melonds"
archrgs_module_desc="Nintendo DS Libretro Core"
archrgs_module_help="ROM Extensions: .nds .zip\n\nCopy your NDS roms to $romdir/nds\n\nCopy the required BIOS files\n\bios7.bin and\bios9.bin and\firmware.bin to\n\n$biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/melonDS/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-melonds() {
  pacmanPkg rgs-lr-melonds
}

function remove_rgs-lr-melonds() {
  pacmanRemove rgs-lr-melonds
}

function configure_rgs-lr-melonds() {
  mkRomDir "nds"
  
  ensureSystemretroconfig "nds"
  
  addEmulator 0 "$md_id" "nds" "$md_inst/melonds_libretro.so"
  addSystem "nds"
}

