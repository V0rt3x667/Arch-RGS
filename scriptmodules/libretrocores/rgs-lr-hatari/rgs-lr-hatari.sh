#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-hatari"
archrgs_module_desc="Atari ST, STE, TT & Falcon Libretro Core"
archrgs_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr .zip\n\nCopy Your Atari ST Games to $romdir/atarist"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/hatari/master/gpl.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-hatari() {
  pacmanPkg rgs-lr-hatari
}

function remove_rgs-lr-hatari() {
  pacmanRemove rgs-lr-hatari
}

function configure_rgs-lr-hatari() {
  mkRomDir "atarist"
  
  ensureSystemretroconfig "atarist"
  
  moveConfigDir "$home/.hatari" "$md_conf_root/atarist"
  
  addEmulator 1 "$md_id" "atarist" "$md_inst/hatari_libretro.so"
  addSystem "atarist"
  
  # add LD_LIBRARY_PATH='$md_inst' to start of launch command
  #iniConfig " = " '"' "$configdir/atarist/emulators.cfg"
  #iniGet "$md_id"
  #iniSet "$md_id" "LD_LIBRARY_PATH='$md_inst' $ini_value"
}

