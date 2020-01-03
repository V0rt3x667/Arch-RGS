#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mame"
archrgs_module_desc="MAME emulator - MAME (current) port for libretro"
archrgs_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mame() {
    pacmanPkg rgs-lr-mame
}

function remove_rgs-lr-mame() {
    pacmanRemove rgs-lr-mame
}

function configure_rgs-lr-mame() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade_libretro.so"
        addSystem "$system"
    done
}