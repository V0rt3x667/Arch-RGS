#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-np2kai"
archrgs_module_desc="NEC PC-9800 Libretro Core"
archrgs_module_help="ROM Extensions: .d88 .d98 .88d .98d .fdi .xdf .hdm .dup .2hd .tfd .hdi .thd .nhd .hdd\n\nCopy your pc98 games to to $romdir/pc98\n\nCopy bios files 2608_bd.wav, 2608_hh.wav, 2608_rim.wav, 2608_sd.wav, 2608_tom.wav 2608_top.wav, bios.rom, FONT.ROM and sound.rom to $biosdir/np2kai"
archrgs_module_licence="MIT https://raw.githubusercontent.com/libretro/NP2kai/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-np2kai() {
  pacmanPkg rgs-lr-np2kai
}

function remove_rgs-lr-np2kai() {
  pacmanRemove rgs-lr-np2kai
}

function configure_rgs-lr-np2kai() {
  mkRomDir "pc98"

  ensureSystemretroconfig "pc98"

  addEmulator 1 "$md_id" "pc98" "$md_inst/np2kai_libretro.so"
  addSystem "pc98"
}

