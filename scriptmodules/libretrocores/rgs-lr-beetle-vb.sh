#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-vb"
archrgs_module_desc="Virtual Boy emulator - Mednafen VB (optimised) port for libretro"
archrgs_module_help="ROM Extensions: .vb .zip\n\nCopy your Virtual Boy roms to $romdir/virtualboy"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-vb-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-vb() {
    pacmanPkg rgs-lr-beetle-vb
}

function remove_rgs-lr-beetle-vb() {
    pacmanRemove rgs-lr-beetle-vb
}

function configure_rgs-lr-beetle-vb() {
    mkRomDir "virtualboy"
    ensureSystemretroconfig "virtualboy"

    addEmulator 1 "$md_id" "virtualboy" "$md_inst/mednafen_vb_libretro.so"
    addSystem "virtualboy"
}