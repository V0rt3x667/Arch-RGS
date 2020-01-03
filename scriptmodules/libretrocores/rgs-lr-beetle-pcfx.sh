#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-pcfx"
archrgs_module_desc="PCFX emulator - Mednafen PCFX Port for libretro"
archrgs_module_help="ROM Extensions: .img .iso .ccd .cue\n\nCopy the required BIOS file pcfx.rom to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pcfx-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-pcfx() {
    pacmanPkg rgs-lr-beetle-pcfx
}

function remove_rgs-lr-beetle-pcfx() {
    pacmanRemove rgs-lr-beetle-pcfx
}

function configure_rgs-lr-beetle-pcfx() {
    mkRomDir "pcfx"
    ensureSystemretroconfig "pcfx"

    addEmulator 1 "$md_id" "pcfx" "$md_inst/mednafen_pcfx_libretro.so"
    addSystem "pcfx"
}