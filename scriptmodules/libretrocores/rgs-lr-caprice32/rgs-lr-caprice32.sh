#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-caprice32"
archrgs_module_desc="Amstrad CPC Libretro Core"
archrgs_module_help="ROM Extensions: .cdt .cpc .dsk\n\nCopy your Amstrad CPC games to $romdir/amstradcpc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-cap32/master/cap32/COPYING.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-caprice32() {
  pacmanPkg rgs-lr-caprice32
}

function remove_rgs-lr-caprice32() {
  pacmanRemove rgs-lr-caprice32
}

function configure_rgs-lr-caprice32() {
  mkRomDir "amstradcpc"

  addEmulator 1 "$md_id" "amstradcpc" "$md_inst/cap32_libretro.so"
  addSystem "amstradcpc"

  [[ "$md_mode" == "remove" ]] && return

  ensureSystemretroconfig "amstradcpc"

  setRetroArchCoreOption "cap32_autorun" "enabled"
  setRetroArchCoreOption "cap32_Model" "6128"
  setRetroArchCoreOption "cap32_Ram" "128"
  setRetroArchCoreOption "cap32_combokey" "y"
}

