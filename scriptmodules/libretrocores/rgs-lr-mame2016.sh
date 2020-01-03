#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mame2016"
archrgs_module_desc="MAME emulator - MAME 0.174 port for libretro"
archrgs_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame2016-libretro/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mame2016() {
    pacmanPkg rgs-lr-mame2016
}

function remove_rgs-lr-mame2016() {
    pacmanRemove rgs-lr-mame2016
}

function configure_rgs-lr-mame2016() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade2016_libretro.so"
        addSystem "$system"
    done
}