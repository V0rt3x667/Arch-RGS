#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-smsplus-gx"
archrgs_module_desc="Sega Master System & Game Gear Libretro Core"
archrgs_module_help="ROM Extensions: .gg .sms .bin .zip\nCopy Your Game Gear ROMs to $romdir/gamegear\nMasterSystem ROMs to $romdir/mastersystem"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/smsplus-gx/master/docs/license"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-smsplus-gx() {
  pacmanPkg rgs-lr-smsplus-gx
}

function remove_rgs-lr-smsplus-gx() {
  pacmanRemove rgs-lr-smsplus-gx
}

function configure_rgs-lr-smsplus-gx() {
  local system
  for system in gamegear mastersystem; do
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/smsplus_libretro.so"
    addSystem "$system"
  done
}

