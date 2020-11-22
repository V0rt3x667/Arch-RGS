#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-puae"
archrgs_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core"
archrgs_module_help="ROM Extensions: .adf .uae\n\nCopy your roms to $romdir/amiga and create configs as .uae"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-puae() {
  pacmanPkg rgs-lr-puae
}

function remove_rgs-lr-puae() {
  pacmanRemove rgs-lr-puae
}

function configure_rgs-lr-puae() {
  mkRomDir "amiga"

  ensureSystemretroconfig "amiga"

  addEmulator 1 "$md_id" "amiga" "$md_inst/puae_libretro.so"
  addSystem "amiga"
}

