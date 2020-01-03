#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-psx"
archrgs_module_desc="PlayStation emulator - Mednafen PSX Port for libretro"
archrgs_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy the required BIOS files\n\nscph5500.bin and\nscph5501.bin and\nscph5502.bin to\n\n$biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-psx-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-psx() {
    pacmanPkg rgs-lr-beetle-psx
}

function remove_rgs-lr-beetle-psx() {
    pacmanRemove rgs-lr-beetle-psx
}

function configure_rgs-lr-beetle-psx() {
    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    addEmulator 0 "$md_id-hw" "psx" "$md_inst/mednafen_psx_hw_libretro.so"
    addEmulator 1 "$md_id" "psx" "$md_inst/mednafen_psx_libretro.so"
    addSystem "psx"
}
