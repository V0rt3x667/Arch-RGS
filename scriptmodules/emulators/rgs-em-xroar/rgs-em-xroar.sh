#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-xroar"
archrgs_module_desc="XRoar - Dragon Data Dragon 32 & 64 & Tandy Colour Computer (CoCo) 1 & 2 Emulator"
archrgs_module_help="ROM Extensions: .cas .wav .bas .asc .dmk .jvc .os9 .dsk .vdk .rom .ccc .sna\n\nCopy Your Dragon ROMs to $romdir/dragon32\n\nCopy Your CoCo Games to $romdir/coco\n\nCopy the required BIOS files d32.rom (Dragon 32) and bas13.rom (CoCo) to $biosdir"
archrgs_module_licence="GPL3 http://www.6809.org.uk/xroar"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-xroar() {
  pacmanPkg rgs-em-xroar
}

function remove_rgs-em-xroar() {
  pacmanRemove rgs-em-xroar
}

function configure_rgs-em-xroar() {
  mkRomDir "dragon32"
  mkRomDir "coco"

  mkdir -p "$md_inst/share/xroar"
  ln -snf "$biosdir" "$md_inst/share/xroar/roms"

  addEmulator 1 "$md_id-dragon32" "dragon32" "$md_inst/bin/xroar -fs -machine dragon32 -run %ROM%"
  addEmulator 1 "$md_id-cocous" "coco" "$md_inst/bin/xroar -fs -machine cocous -run %ROM%"
  addEmulator 0 "$md_id-coco" "coco" "$md_inst/bin/xroar -fs -machine coco -run %ROM%"
  addSystem "dragon32"
  addSystem "coco"
}

