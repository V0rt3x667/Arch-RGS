#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-duckstation"
archrgs_module_desc="DuckStation - Sony PlayStation Emulator"
archrgs_module_help="ROM Extensions: .bin .cue .chd .img\n\nCopy Your PSX ROMs to $romdir/psx\n\nCopy the required BIOS file(s) ps-30a, ps-30e, ps-30j, scph5500.bin, scph5501.bin, and scph5502.bin to the $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-duckstation() {
  pacmanPkg rgs-em-duckstation
}

function remove_rgs-em-duckstation() {
  pacmanRemove rgs-em-duckstation
}

function configure_rgs-em-duckstation() {
  mkRomDir "psx"

  moveConfigDir "$home/.local/share/duckstation" "$md_conf_root/psx"
  mkUserDir "$md_conf_root/psx/bios"

  local bios
  bios=(
    'ps-30a'
    'ps-30e'
    'ps-30j'
    'scph5500.bin'
    'scph5501.bin'
    'scph5502.bin'
  )

  for file in "${bios[@]}"; do
    ln -sf "$biosdir/$file" "$md_conf_root/psx/bios/$file"
  done

  addEmulator 1 "$md_id" "psx" "$md_inst/duckstation-nogui -fullscreen %ROM%"
  addEmulator 0 "$md_id-gui" "psx" "$md_inst/duckstation-qt -fullscreen %ROM%"
  addSystem "psx"
}

