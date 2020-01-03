#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-px68k"
archrgs_module_desc="SHARP X68000 Emulator"
archrgs_module_help="You need to copy a X68000 bios file (iplrom30.dat, iplromco.dat, iplrom.dat, or iplromxv.dat), and the font file (cgrom.dat or cgrom.tmp) to $biosdir/keropi. Use F12 to access the in emulator menu."
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-px68k() {
    pacmanPkg rgs-em-px68k
}

function remove_rgs-em-px68k() {
    pacmanRemove rgs-em-px68k
}

function configure_rgs-em-px68k() {
    mkRomDir "x68000"

    moveConfigDir "$home/.keropi" "$md_conf_root/x68000"
    mkUserDir "$biosdir/keropi"

    local bios
    for bios in cgrom.dat iplrom30.dat iplromco.dat iplrom.dat iplromxv.dat; do
        if [[ -f "$biosdir/$bios" ]]; then
            mv "$biosdir/$bios" "$biosdir/keropi/$bios"
        fi
        ln -sf "$biosdir/keropi/$bios" "$md_conf_root/x68000/$bios"
    done

    addEmulator 1 "$md_id" "x68000" "$md_inst/px68k %ROM%"
    addSystem "x68000"
}
