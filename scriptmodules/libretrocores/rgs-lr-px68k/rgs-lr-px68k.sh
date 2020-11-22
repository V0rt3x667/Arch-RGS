#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-px68k"
archrgs_module_desc="Sharp X68000 Libretro Core"
archrgs_module_help="You need to copy a X68000 bios file (iplrom30.dat, iplromco.dat, iplrom.dat, or iplromxv.dat) and the font file (cgrom.dat or cgrom.tmp) to $romdir/BIOS/keropi. Use F12 to access the emulator menu."
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-px68k() {
  pacmanPkg rgs-lr-px68k
}

function remove_rgs-lr-px68k() {
  pacmanRemove rgs-lr-px68k
}

function configure_rgs-lr-px68k() {
  mkRomDir "x68000"
  mkUserDir "$biosdir/keropi"

  ensureSystemretroconfig "x68000"

  addEmulator 1 "$md_id" "x68000" "$md_inst/px68k_libretro.so"
  addSystem "x68000"
}

