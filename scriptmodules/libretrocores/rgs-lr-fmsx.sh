#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-fmsx"
archrgs_module_desc="Microsoft MSX,MSX2 & MSX2+ Libretro Core"
archrgs_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fmsx-libretro/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-fmsx() {
    pacmanPkg rgs-lr-fmsx
}

function remove_rgs-lr-fmsx() {
    pacmanRemove rgs-lr-fmsx
}

function configure_rgs-lr-fmsx() {
    mkRomDir "msx"
    ensureSystemretroconfig "msx"

    #Default to MSX2+ Core
    setRetroArchCoreOption "fmsx_mode" "MSX2+"

    addEmulator 0 "$md_id" "msx" "$md_inst/fmsx_libretro.so"
    addSystem "msx"

    [[ "$md_mode" == "remove" ]] && return

    #Copy BIOS Files
    cp "$md_inst/"ROMS/{*.ROM,*.FNT,*.SHA} "$biosdir/"
    chown "$user:$user" "$biosdir/"{*.ROM,*.FNT,*.SHA}
}
