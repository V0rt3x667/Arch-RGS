#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-flycast"
archrgs_module_desc="Sega Dreamcast & Naomi Atomiswave Libretro Core"
archrgs_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd, Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-flycast() {
    pacmanPkg rgs-lr-flycast
}

function remove_rgs-lr-flycast() {
    pacmanRemove rgs-lr-flycast
}

function configure_rgs-lr-flycast() {
    mkRomDir "dreamcast"
    mkUserDir "$biosdir/dc"
    
    ensureSystemretroconfig "dreamcast"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/flycast_libretro.so"
    addSystem "dreamcast"
}
