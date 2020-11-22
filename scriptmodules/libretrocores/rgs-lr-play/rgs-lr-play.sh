#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-play"
archrgs_module_desc="Sony PlayStation 2 Libretro Core"
archrgs_module_help="ROM Extensions: .iso .cue\n\nCopy your PlayStation 2 roms to $romdir/ps2"
archrgs_module_licence="MIT https://raw.githubusercontent.com/jpd002/Play-/master/License.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-play() {
  pacmanPkg rgs-lr-play
}

function remove_rgs-lr-play() {
  pacmanRemove rgs-lr-play
}

function configure_rgs-lr-play() {
  mkRomDir "ps2"

  ensureSystemretroconfig "ps2"

  addEmulator 0 "$md_id" "ps2" "$md_inst/play_libretro.so"
  addSystem "ps2"
}

