#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-atari800"
archrgs_module_desc="Atari 400, 800, 600XL, 800XL, 130XE & 5200 Emulator"
archrgs_module_help="ROM Extensions: .a52 .atr .atr.gz .bas .bin .car .dcm .xex .xfd .xfd.gz\n\nCopy Your Atari800 ROMs to: $romdir/atari800\n\nCopy Your Atari 5200 ROMs to: $romdir/atari5200.\n\nYou Need to Copy the Atari 800/5200 BIOS Files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to: $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/atari800/atari800/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-atari800() {
  pacmanPkg rgs-em-atari800
}

function remove_rgs-em-atari800() {
  pacmanRemove rgs-em-atari800
}

function configure_rgs-em-atari800() {
  mkRomDir "atari800"
  mkRomDir "atari5200"

  if [[ "$md_mode" == "install" ]]; then
    mkUserDir "$md_conf_root/atari800"
      ##Move Old Config If Exists To New Location
      if [[ -f "$md_conf_root/atari800.cfg" ]]; then
        mv "$md_conf_root/atari800.cfg" "$md_conf_root/atari800/atari800.cfg"
      fi
    moveConfigFile "$home/.atari800.cfg" "$md_conf_root/atari800/atari800.cfg"
    ##Copy Launch Script
    install -Dm755 "$md_data/atari800.sh" "$md_inst"
    chmod a+x "$md_inst/atari800.sh"
  fi

  addEmulator 1 "atari800-800-pal" "atari800" "$md_inst/atari800.sh %ROM% Atari800-PAL"
  addEmulator 1 "atari800-800-ntsc" "atari800" "$md_inst/atari800.sh %ROM% Atari800-NTSC"
  addEmulator 1 "atari800-800xl" "atari800" "$md_inst/atari800.sh %ROM% Atari800XL"
  addEmulator 1 "atari800-130xe" "atari800" "$md_inst/atari800.sh %ROM% Atari130XE"
  addEmulator 1 "atari800-5200" "atari5200" "$md_inst/atari800.sh %ROM% Atari5200"

  addSystem "atari800"
  addSystem "atari5200"
}

