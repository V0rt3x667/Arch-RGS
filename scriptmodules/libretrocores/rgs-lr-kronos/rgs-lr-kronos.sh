#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-kronos"
archrgs_module_desc="Saturn & ST-V Libretro Core"
archrgs_module_help="ROM Extensions: .iso .cue .zip .ccd .mds\n\nCopy your Sega Saturn & ST-V roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin / stvbios.zip to $biosdir/kronos"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro-mirrors/Kronos/extui-align/yabause/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-kronos() {
  pacmanPkg rgs-lr-kronos
}

function remove_rgs-lr-kronos() {
  pacmanRemove rgs-lr-kronos
}

function configure_rgs-lr-kronos() {
  mkRomDir "saturn"

  ensureSystemretroconfig "saturn"

  addEmulator 1 "$md_id" "saturn" "$md_inst/kronos_libretro.so"
  addSystem "saturn"
}

