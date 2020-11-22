#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-freeintv"
archrgs_module_desc="Mattel Intellivision Libretro Core"
archrgs_module_help="ROM Extensions: .int .bin\n\nCopy your Intellivision roms to $romdir/intellivision\n\nCopy the required BIOS files exec.bin and grom.bin to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/FreeIntv/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-freeintv() {
  pacmanPkg rgs-lr-freeintv
}

function remove_rgs-lr-freeintv() {
  pacmanRemove rgs-lr-freeintv
}

function configure_rgs-lr-freeintv() {
  mkRomDir "intellivision"

  ensureSystemretroconfig "intellivision"

  addEmulator 1 "$md_id" "intellivision" "$md_inst/freeintv_libretro.so"
  addSystem "intellivision"
}

