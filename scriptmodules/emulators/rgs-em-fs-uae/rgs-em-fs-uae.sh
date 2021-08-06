#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution

archrgs_module_id="rgs-em-fs-uae"
archrgs_module_desc="FS-UAE - Commodore Amiga 500, 500+, 600, 1200, CDTV & CD32 Emulator"
archrgs_module_help="ROM Extension: .adf .adz .dms .ipf .zip .lha .iso .cue .bin\n\nCopy Your Amiga Games to $romdir/amiga.\nCopy Your CD32 Games to $romdir/cd32.\nCopy Your CDTV Games to $romdir/cdtv.\n\nCopy a required BIOS file (e.g. kick13.rom) to $biosdir."
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/FrodeSolheim/fs-uae/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-fs-uae() {
  pacmanPkg rgs-em-fs-uae
}

function remove_rgs-em-fs-uae() {
  pacmanRemove rgs-em-fs-uae
}

function configure_rgs-em-fs-uae() {
  setConfigRoot ""

  addEmulator 0 "fs-uae-a500+" "amiga" "$md_inst/fs-uae.sh %ROM% A500+"
  addEmulator 1 "fs-uae-a500" "amiga" "$md_inst/fs-uae.sh %ROM% A500"
  addEmulator 0 "fs-uae-a600" "amiga" "$md_inst/fs-uae.sh %ROM% A600"
  addEmulator 0 "fs-uae-a1200" "amiga" "$md_inst/fs-uae.sh %ROM% A1200"
  addEmulator 1 "fs-uae-cd32" "cd32" "$md_inst/fs-uae.sh %ROM% CD32"
  addEmulator 1 "fs-uae-cdtv" "cdtv" "$md_inst/fs-uae.sh %ROM% CDTV"
  addEmulator 0 "fs-uae-gui" "amiga" "$md_inst/fs-uae.sh %ROM% GUI"
  addSystem "amiga"
  addSystem "cd32"
  addSystem "cdtv"

  moveConfigDir "$home/.config/fs-uae" "$configdir/amiga/fs-uae" 

  [[ "$md_mode" == "remove" ]] && return

  mkRomDir "amiga"
  mkRomDir "cd32"
  mkRomDir "cdtv"

  ##Copy Start Script
  cp "$md_data/fs-uae.sh" "$md_inst"
  chmod +x "$md_inst/fs-uae.sh"

  ##Copy Default Config File
  local config="$(mktemp)"
  iniConfig " = " "" "$config"
  iniSet "base_dir" "$home/.config/fs-uae"
  iniSet "kickstarts_dir" "$datadir/bios"
  iniSet "fullscreen" "1"
  iniSet "keep_aspect" "1"
  iniSet "zoom" "full"
  iniSet "fsaa" "0"
  iniSet "scanlines" "0"
  iniSet "floppy_drive_speed" "100"
  copyDefaultConfig "$config" "$home/.config/fs-uae/fs-uae.conf"
  rm "$config"
}

