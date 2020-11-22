#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-ppsspp"
archrgs_module_desc="PPSSPP - Sony PlayStation Portable Emulator"
archrgs_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
archrgs_module_section="emulators"

function install_bin_rgs-em-ppsspp() {
  pacmanPkg rgs-em-ppsspp
}

function remove_rgs-em-ppsspp() {
  pacmanRemove rgs-em-ppsspp
}

function configure_rgs-em-ppsspp() {
  mkRomDir "psp"
  
  moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
  mkUserDir "$md_conf_root/psp/PSP"
  ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"

  addEmulator 1 "$md_id" "psp" "ppsspp --fullscreen %ROM%"
  addSystem "psp"
}

