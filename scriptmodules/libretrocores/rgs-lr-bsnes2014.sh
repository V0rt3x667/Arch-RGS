#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-bsnes2014"
archrgs_module_desc="Super Nintendo emu - bsnes port for libretro"
archrgs_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes-libretro/libretro/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-bsnes2014() {
    pacmanPkg rgs-lr-bsnes2014
}

function remove_rgs-lr-bsnes2014() {
    pacmanRemove rgs-lr-bsnes2014
}

function configure_rgs-lr-bsnes2014() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/bsnes2014_accuracy_libretro.so"
    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes2014_balanced_libretro.so"
    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes2014_performance_libretro.so"
    addSystem "snes"
}