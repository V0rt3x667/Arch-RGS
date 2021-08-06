#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-o2em"
archrgs_module_desc="Magnavox Odyssey 2 (Philips VideoPac) Libretro Core"
archrgs_module_help="ROM Extensions: .bin .zip\n\nCopy Your Odyssey 2 / Videopac ROMs to $romdir/videopac\n\nCopy the required BIOS file o2rom.bin to $biosdir"
archrgs_module_licence="Artistic License 2.0 https://raw.githubusercontent.com/libretro/libretro-o2em/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-o2em() {
  pacmanPkg rgs-lr-o2em
}

function remove_rgs-lr-o2em() {
  pacmanRemove rgs-lr-o2em
}

function configure_rgs-lr-o2em() {
  mkRomDir "videopac"

  ensureSystemretroconfig "videopac"

  addEmulator 1 "$md_id" "videopac" "$md_inst/o2em_libretro.so"
  addSystem "videopac"
}

