#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-stella2014"
archrgs_module_desc="Atari 2600 emulator - Stella port for libretro"
archrgs_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/stella-libretro/master/stella/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-stella2014() {
    pacmanPkg rgs-lr-stella2014
}

function remove_rgs-lr-stella2014() {
    pacmanRemove rgs-lr-stella2014
}

function configure_rgs-lr-stella2014() {
    mkRomDir "atari2600"
    ensureSystemretroconfig "atari2600"

    addEmulator 1 "$md_id" "atari2600" "$md_inst/stella2014_libretro.so"
    addSystem "atari2600"
}
