#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-sameboy"
archrgs_module_desc="Nintendo Game Boy\Game Boy Color core for libretro"
archrgs_module_help="ROM Extensions: .gb .gbc .zip\n\nCopy your Game Boy roms to $romdir/gb\nGame Boy Color roms to $romdir/gbc\nCopy the recommended BIOS files gb_bios.bin and gbc_bios.bin to $biosdir"
archrgs_module_licence="MIT https://raw.githubusercontent.com/SameBoy/sameboy.github.io/master/minima-license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-sameboy() {
    pacmanPkg rgs-lr-sameboy
}

function remove_rgs-lr-sameboy() {
    pacmanRemove rgs-lr-sameboy
}

function configure_rgs-lr-sameboy() {
    local system
    local def
    for system in gb gbc; do
        def=0
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/sameboy_libretro.so"
        addSystem "$system"
done
}
