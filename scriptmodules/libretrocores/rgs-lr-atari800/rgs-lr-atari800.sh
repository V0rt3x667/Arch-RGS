#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-atari800"
archrgs_module_desc="Atari 5200, 400, 800, XL & XE Libretro Core"
archrgs_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopy your Atari800 games to $romdir/atari800\n\nCopy your Atari 5200 roms to $romdir/atari5200 You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-atari800/master/atari800/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-atari800() {
  pacmanPkg rgs-lr-atari800
}

function remove_rgs-lr-atari800() {
  pacmanRemove rgs-lr-atari800
}

function configure_rgs-lr-atari800() {
  mkRomDir "atari800"
  mkRomDir "atari5200"

  ensureSystemretroconfig "atari800"
  ensureSystemretroconfig "atari5200"

  mkUserDir "$md_conf_root/atari800"
  moveConfigFile "$home/.libretro-atari800.cfg" "$md_conf_root/atari800/libretro-atari800.cfg"

  addEmulator 0 "rgs-lr-atari800" "atari800" "$md_inst/atari800_libretro.so"
  addEmulator 0 "rgs-lr-atari800" "atari5200" "$md_inst/atari800_libretro.so"
    
  addSystem "atari800"
  addSystem "atari5200"
}
