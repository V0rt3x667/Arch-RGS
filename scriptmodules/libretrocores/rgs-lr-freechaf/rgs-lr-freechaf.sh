#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-freechaf"
archrgs_module_desc="Fairchild ChannelF Libretro Core"
archrgs_module_help="ROM Extensions: .bin .rom\n\nCopy Your ChannelF ROMs to $romdir/channelf\n\nCopy the required BIOS files sl31245.bin and sl31253.bin or sl90025.bin to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/FreeChaF/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-freechaf() {
  pacmanPkg rgs-lr-freechaf
}

function remove_rgs-lr-freechaf() {
  pacmanRemove rgs-lr-freechaf
}

function configure_rgs-lr-freechaf() {
  mkRomDir "channelf"

  ensureSystemretroconfig "channelf"

  addEmulator 1 "$md_id" "channelf" "$md_inst/freechaf_libretro.so"
  addSystem "channelf"
}

