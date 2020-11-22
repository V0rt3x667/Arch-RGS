#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-pokemini"
archrgs_module_desc="Pokémon-Mini Libretro Core"
archrgs_module_help="ROM Extensions: .min .zip\n\nCopy your Pokemon Mini roms to $romdir/pokemini"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/PokeMini/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-pokemini() {
  pacmanPkg rgs-lr-pokemini
}

function remove_rgs-lr-pokemini() {
  pacmanRemove rgs-lr-pokemini
}

function configure_rgs-lr-pokemini() {
  mkRomDir "pokemini"

  ensureSystemretroconfig "pokemini"

  addEmulator 1 "$md_id" "pokemini" "$md_inst/pokemini_libretro.so"
  addSystem "pokemini"
}

