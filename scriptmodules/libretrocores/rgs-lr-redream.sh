#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-redream"
archrgs_module_desc="Dreamcast emulator - redream port for libretro"
archrgs_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/redream/master/LICENSE.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-redream() {
    pacmanPkg rgs-lr-redream
}

function remove_rgs-lr-redream() {
    pacmanRemove rgs-lr-redream
}

function configure_rgs-lr-redream() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/redream_libretro.so"
    addSystem "dreamcast"
}