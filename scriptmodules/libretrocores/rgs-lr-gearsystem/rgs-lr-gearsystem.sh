#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-gearsystem"
archrgs_module_desc="Sega Master System, Game Gear & SG-1000 Libretro Core"
archrgs_module_help="ROM Extensions: .gg .sg .sms .bin .zip\nCopy Your Game Gear ROMs to $romdir/gamegear\nMasterSystem ROMs to $romdir/mastersystem\nSG-1000 ROMs to $romdir/sg-1000"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Gearsystem/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-gearsystem() {
  pacmanPkg rgs-lr-gearsystem
}

function remove_rgs-lr-gearsystem() {
  pacmanRemove rgs-lr-gearsystem
}

function configure_rgs-lr-gearsystem() {
  local system
  for system in gamegear mastersystem sg-1000; do
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/gearsystem_libretro.so"
    addSystem "$system"
  done
}

