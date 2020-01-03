#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mupen64plus-next"
archrgs_module_desc="N64 emulator - Mupen64Plus + GLideN64 for libretro (next version)"
archrgs_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mupen64plus-libretro-nx/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mupen64plus-next() {
    pacmanPkg rgs-lr-mupen64plus-next
}

function remove_rgs-lr-mupen64plus-next() {
    pacmanRemove rgs-lr-mupen64plus-next
}

function configure_rgs-lr-mupen64plus-next() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    addEmulator 0 "$md_id" "n64" "$md_inst/mupen64plus_next_libretro.so"
    addSystem "n64"
}