#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-dosbox"
archrgs_module_desc="DOSBox Libretro Core"
archrgs_module_help="ROM Extensions: .bat .com .exe .sh\n\nCopy Your DOS Games to $ROMDIR/pc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dosbox-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-dosbox() {
  pacmanPkg rgs-lr-dosbox
}

function remove_rgs-lr-dosbox() {
  pacmanRemove rgs-lr-dosbox
}

function configure_rgs-lr-dosbox() {
  mkRomDir "pc"
  ensureSystemretroconfig "pc"

  addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_libretro.so"
  addSystem "pc"
}

