#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-snes9x"
archrgs_module_desc="SNES9X - Super Nintendo Entertainment System Emulator"
archrgs_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/snes9xgit/snes9x/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-snes9x() {
  pacmanPkg rgs-em-snes9x
}

function remove_rgs-em-snes9x() {
  pacmanRemove rgs-em-snes9x
}

function configure_rgs-em-snes9x() {
  mkRomDir "snes"

  moveConfigDir "$home/.config/snes9x" "$md_conf_root/snes/snes9x"

  addEmulator 1 "$md_id" "snes" "$md_inst/bin/snes9x-gtk -fullscreen %ROM%"
  addSystem "snes"
}

