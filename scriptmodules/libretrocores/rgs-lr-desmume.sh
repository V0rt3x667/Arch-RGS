#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-desmume"
archrgs_module_desc="NDS emu - DESMUME"
archrgs_module_help="ROM Extensions: .nds .zip\n\nCopy your Nintendo DS roms to $romdir/nds"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/desmume/master/desmume/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-desmume() {
    pacmanPkg rgs-lr-desmume
}

function remove_rgs-lr-desmume() {
    pacmanRemove rgs-lr-desmume
}

function configure_rgs-lr-desmume() {
    mkRomDir "nds"
    ensureSystemretroconfig "nds"

    addEmulator 0 "$md_id" "nds" "$md_inst/desmume_libretro.so"
    addSystem "nds"
}