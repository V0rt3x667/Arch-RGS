#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-x1"
archrgs_module_desc="Sharp X1 emulator - X Millenium port for libretro"
archrgs_module_help="ROM Extensions: .dx1 .zip .2d .2hd .tfd .d88 .88d .hdm .xdf .dup .cmd\n\nCopy your X1 roms to $romdir/x1\n\nCopy the required BIOS files IPLROM.X1 and IPLROM.X1T to $biosdir"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-x1() {
    pacmanPkg rgs-lr-x1
}

function remove_rgs-lr-x1() {
    pacmanRemove rgs-lr-x1
}

function configure_rgs-lr-x1() {
    mkRomDir "x1"
    ensureSystemretroconfig "x1"

    addEmulator 1 "$md_id" "x1" "$md_inst/x1_libretro.so"
    addSystem "x1"
}