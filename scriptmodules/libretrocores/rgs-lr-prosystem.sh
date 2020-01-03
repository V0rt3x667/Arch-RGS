#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-prosystem"
archrgs_module_desc="Atari 7800 ProSystem emu - ProSystem port for libretro"
archrgs_module_help="ROM Extensions: .a78 .bin .zip\n\nCopy your Atari 7800 roms to $romdir/atari7800\n\nCopy the optional BIOS file 7800 BIOS (U).rom to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/prosystem-libretro/master/License.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-prosystem() {
    pacmanPkg rgs-lr-prosystem
}

function remove_rgs-lr-prosystem() {
    pacmanRemove rgs-lr-prosystem
}

function configure_rgs-lr-prosystem() {
    mkRomDir "atari7800"

    ensureSystemretroconfig "atari7800"

    addEmulator 1 "$md_id" "atari7800" "$md_inst/prosystem_libretro.so"
    addSystem "atari7800"
}