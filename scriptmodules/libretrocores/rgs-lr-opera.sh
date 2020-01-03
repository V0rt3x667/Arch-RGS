#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-opera"
archrgs_module_desc="3DO Emulator - 4DO/FreeDO for Libretro"
archrgs_module_help="ROM Extension: .iso\n\nCopy your 3do roms to $romdir/3do\n\nCopy the required BIOS file panazf10.bin to $biosdir"
archrgs_module_licence="LGPL https://raw.githubusercontent.com/libretro/opera-libretro/master/libfreedo/freedo_3do.c"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-opera() {
    pacmanPkg rgs-lr-opera
}

function remove_rgs-lr-opera() {
    pacmanRemove rgs-lr-opera
}

function configure_rgs-lr-opera() {
    mkRomDir "3do"
    ensureSystemretroconfig "3do"
	
	addEmulator 1 "$md_id" "3do" "$md_inst/opera_libretro.so"
    addSystem "3do"
}