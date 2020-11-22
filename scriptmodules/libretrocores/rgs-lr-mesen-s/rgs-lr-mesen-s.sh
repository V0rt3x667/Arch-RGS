#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mesen-s"
archrgs_module_desc="Nintendo SNES (Super Famicom), Game Boy, Game Boy Color & Super Game Boy Libretro Core"
archrgs_module_help="ROM Extensions: .sfc .smc .fig .swc .bs .gb .gbc\n\nCopy your Game Boy roms to $romdir/gb\n\nCopy your Game Boy Color roms to $romdir/gbc\n\nCopy your SNES roms to $romdir/snes"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen-S/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mesen-s() {
  pacmanPkg rgs-lr-mesen-s
}

function remove_rgs-lr-mesen-s() {
  pacmanRemove rgs-lr-mesen-s
}

function configure_rgs-lr-mesen-s() {
  local system
  for system in "snes" "gb" "gbc"; do
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/mesen_libretro.so"
    addSystem "$system"
  done
}

