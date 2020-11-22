#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mesen"
archrgs_module_desc="Nintendo NES (Famicom) & Famicom Disk System Libretro Core"
archrgs_module_help="ROM Extensions: .nes .fds .unf .unif\n\nCopy your NES roms to $romdir/nes\nFamicom roms to $romdir/fds\nCopy the recommended BIOS file disksys.rom to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mesen() {
  pacmanPkg rgs-lr-mesen
}

function remove_rgs-lr-mesen() {
  pacmanRemove rgs-lr-mesen
}

function configure_rgs-lr-mesen() {
  local system

  for system in "nes" "fds"; do
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/mesen_libretro.so"
    addSystem "$system"
  done
}

