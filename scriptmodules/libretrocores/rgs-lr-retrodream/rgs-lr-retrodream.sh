#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-retrodream"
archrgs_module_desc="Sega Dreamcast Libretro Core"
archrgs_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/retrodream/master/LICENSE.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-retrodream() {
  pacmanPkg rgs-lr-retrodream
}

function remove_rgs-lr-retrodream() {
  pacmanRemove rgs-lr-retrodream
}

function configure_rgs-lr-retrodream() {
  mkRomDir "dreamcast"
  mkUserDir "$biosdir/dc"

  ensureSystemretroconfig "dreamcast"

  addEmulator 0 "$md_id" "dreamcast" "$md_inst/retrodream_libretro.so"
  addSystem "dreamcast"
}

