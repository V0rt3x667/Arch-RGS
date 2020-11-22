#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-stella"
archrgs_module_desc="Stella - Atari 2600 VCS Emulator"
archrgs_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/stella-emu/stella/master/License.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-stella() {
  pacmanPkg rgs-em-stella
}

function remove_rgs-em-stella() {
  pacmanRemove rgs-em-stella
}

function configure_rgs-em-stella() {
  mkRomDir "atari2600"

  moveConfigDir "$home/.config/stella" "$md_conf_root/atari2600/stella"

  addEmulator 1 "$md_id" "atari2600" "$md_inst/bin/stella -maxres 320x240 -fullscreen 1 -tia.fsfill 1 %ROM%"
  addSystem "atari2600"
}

