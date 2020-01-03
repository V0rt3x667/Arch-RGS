#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mame2010"
archrgs_module_desc="Arcade emu - MAME 0.139 port for libretro"
archrgs_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2010-libretro/master/docs/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mame2010() {
    pacmanPkg rgs-lr-mame2010
}

function remove_rgs-lr-mame2010() {
    pacmanRemove rgs-lr-mame2010
}

function configure_rgs-lr-mame2010() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2010_libretro.so"
        addSystem "$system"
    done
}