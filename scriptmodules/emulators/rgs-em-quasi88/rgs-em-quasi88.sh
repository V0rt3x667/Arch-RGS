#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-quasi88"
archrgs_module_desc="QUASI88 - NEC PC-8801 Emulator"
archrgs_module_help="ROM Extensions: .d88 .88d .cmt .t88\n\nCopy your pc88 games to to $romdir/pc88\n\nCopy bios files FONT.ROM, N88.ROM, N88KNJ1.ROM, N88KNJ2.ROM, and N88SUB.ROM to $biosdir/pc88"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-quasi88() {
  pacmanPkg rgs-em-quasi88
}

function remove_rgs-em-quasi88() {
  pacmanRemove rgs-em-quasi88
}

function configure_rgs-em-quasi88() {
  mkRomDir "pc88"
  mkUserDir "$biosdir/pc88"

  moveConfigDir "$home/.quasi88" "$md_conf_root/pc88"

  addEmulator 1 "$md_id" "pc88" "$md_inst/quasi88.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAIT -f9 ROMAJI -f10 NUMLOCK -fullscreen %ROM%"
  addSystem "pc88"
}
