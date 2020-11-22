#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-duckstation"
archrgs_module_desc="Sony Playstation Libretro Core"
archrgs_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy the required BIOS files\n\nscph5500.bin and\nscph5501.bin and\nscph5502.bin to\n\n$biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-duckstation() {
  pacmanPkg rgs-lr-duckstation
}

function remove_rgs-lr-duckstation() {
  pacmanRemove rgs-lr-duckstation
}

function configure_rgs-lr-duckstation() {
  mkRomDir "psx"
  
  ensureSystemretroconfig "psx"
  
  addEmulator 0 "$md_id" "psx" "$md_inst/duckstation_libretro.so"
  addSystem "psx"
}

