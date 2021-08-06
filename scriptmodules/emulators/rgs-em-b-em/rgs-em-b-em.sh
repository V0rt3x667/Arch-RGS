#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-b-em"
archrgs_module_desc="Acorn BBC Micro A, B, B+, Master 128, 512, Compact & Turbo Emulator"
archrgs_module_help="ROM Extension: .adf .adl .csw .dsd .fdi .img .ssd .uef\n\nCopy Your BBC Micro & Master ROMs to: $romdir/bbcmicro"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/stardot/b-em/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-b-em() {
  pacmanPkg rgs-em-b-em
}

function remove_rgs-em-b-em() {
  pacmanRemove rgs-em-b-em
}

function configure_rgs-em-b-em() {
  mkRomDir "bbcmicro"

  moveConfigDir "$home/.config/b-em" "$md_conf_root/bbcmicro"

  addEmulator 1 "b-em-modelb" "bbcmicro" "$md_inst/b-em %ROM% -m3 -autoboot"
  addEmulator 1 "b-em-modela" "bbcmicro" "$md_inst/b-em %ROM% -m0 -autoboot"
  addEmulator 1 "b-em-bplus" "bbcmicro" "$md_inst/b-em %ROM% -m9 -autoboot"
  addEmulator 1 "b-em-master128" "bbcmicro" "$md_inst/b-em %ROM% -m10 -autoboot"
  addEmulator 1 "b-em-master512" "bbcmicro" "$md_inst/b-em %ROM% -m11 -autoboot"
  addEmulator 1 "b-em-masterturbo" "bbcmicro" "$md_inst/b-em %ROM% -m12 -autoboot"
  addEmulator 1 "b-em-mastercompact" "bbcmicro" "$md_inst/b-em %ROM% -m13 -autoboot"
  addSystem "bbcmicro"
}

