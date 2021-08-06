#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-stratagus"
archrgs_module_desc="Stratagus - Strategy Game Engine to Play Warcraft I, II & Starcraft"
archrgs_module_help="Copy Your Stratagus Games to $romdir/stratagus"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/Wargus/stratagus/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-stratagus() {
  pacmanPkg rgs-em-stratagus
}

function remove_rgs-em-stratagus() {
  pacmanRemove rgs-em-stratagus
}

function configure_rgs-em-stratagus() {
  mkRomDir "stratagus"

  addEmulator 1 "$md_id" "stratagus" "$md_inst/stratagus -F -d %ROM%"
  addSystem "stratagus" "Stratagus Strategy Engine" ".wc1 .wc2 .sc .data"
}

