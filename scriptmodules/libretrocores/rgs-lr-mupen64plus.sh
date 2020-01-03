#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mupen64plus"
archrgs_module_desc="N64 emu - Mupen64Plus + GLideN64 for libretro"
archrgs_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/mupen64plus-libretro/master/LICENSE"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-mupen64plus() {
    pacmanPkg rgs-lr-mupen64plus
}

function remove_rgs-lr-mupen64plus() {
    pacmanRemove rgs-lr-mupen64plus
}

function configure_rgs-lr-mupen64plus() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    addEmulator 0 "$md_id" "n64" "$md_inst/mupen64plus_libretro.so"
    addSystem "n64"
}