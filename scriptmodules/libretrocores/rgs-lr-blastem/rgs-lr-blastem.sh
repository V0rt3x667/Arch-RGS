#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-blastem"
archrgs_module_desc="Sega Mega Drive (Genesis) Libretro Core"
archrgs_module_help="ROM Extensions: .md .bin .smd\n\nCopy Your Sega Mega Drive\Genesis ROMs to $romdir/megadrive or $romdir/genesis\n\n"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/blastem/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-blastem() {
  pacmanPkg rgs-lr-blastem
}

function remove_rgs-lr-blastem() {
  pacmanRemove rgs-lr-blastem
}

function configure_rgs-lr-blastem() {
  mkRomDir "megadrive"
  ensureSystemretroconfig "megadrive"

  addEmulator 0 "$md_id" "megadrive" "$md_inst/blastem_libretro.so"
  addSystem "megadrive"
}

