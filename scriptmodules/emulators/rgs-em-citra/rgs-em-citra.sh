#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-citra"
archrgs_module_desc="Nintendo 3DS Emulator"
archrgs_module_help="ROM Extensions: .3ds .cci .cxi .app .3dsx\n\nCopy Your Nintendo 3DS Games to $romdir/3ds"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/citra-emu/citra/master/license.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-citra() {
  pacmanPkg rgs-em-citra
}

function remove_rgs-em-citra() {
  pacmanRemove rgs-em-citra
}

function configure_rgs-em-citra() {
  mkRomDir "3ds"

  addEmulator 1 "$md_id" "3ds" "$md_inst/bin/citra -f %ROM%"
  addEmulator 0 "$md_id-gui" "3ds" "$md_inst/bin/citra-qt -f %ROM%"

  addSystem "3ds"
}

