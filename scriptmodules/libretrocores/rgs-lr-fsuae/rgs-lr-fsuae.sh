#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-fsuae"
archrgs_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core"
archrgs_module_help="ROM Extension: .adf .adz .dms .ipf .zip .lha .iso .cue .bin\n\nCopy your Amiga games to $romdir/amiga.\nCopy your CD32 games to $romdir/cd32.\nCopy your CDTV games to $romdir/cdtv.\n\nCopy a required BIOS file (e.g. kick13.rom) to $biosdir."
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-fsuae/libretro-fsuae/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-fsuae() {
  pacmanPkg rgs-lr-fsuae
}

function remove_rgs-lr-fsuae() {
  pacmanRemove rgs-lr-fsuae
}

function configure_rgs-lr-fsuae() {
  mkRomDir "amiga"
  
  ensureSystemretroconfig "amiga"
  
  addEmulator 0 "$md_id" "amiga" "$md_inst/fsuae_libretro.so"
  addSystem "amiga"
}

