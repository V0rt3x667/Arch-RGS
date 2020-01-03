#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-supergrafx"
archrgs_module_desc="SuperGrafx TG-16 emulator - Mednafen PCE Fast port for libretro"
archrgs_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopy your PC Engine / TurboGrafx roms to $romdir/pcengine\n\nCopy the required BIOS file syscard3.pce to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-supergrafx-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-supergrafx() {
    pacmanPkg rgs-lr-beetle-supergrafx
}

function remove_rgs-lr-beetle-supergrafx() {
    pacmanRemove rgs-lr-beetle-supergrafx
}

function configure_rgs-lr-beetle-supergrafx() {
    mkRomDir "pcengine"
    ensureSystemretroconfig "pcengine"

    addEmulator 0 "$md_id" "pcengine" "$md_inst/mednafen_supergrafx_libretro.so"
    addSystem "pcengine"
}