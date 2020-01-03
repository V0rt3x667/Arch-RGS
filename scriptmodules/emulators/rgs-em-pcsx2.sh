#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-pcsx2"
archrgs_module_desc="PS2 emulator PCSX2"
archrgs_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .ima .gz\n\nCopy your PS2 roms to $romdir/ps2\n\nCopy the required BIOS file to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-pcsx2() {
    pacmanPkg rgs-em-pcsx2
}

function remove_bin_rgs-em-pcsx2() {
    pacmanRemove rgs-em-pcsx2
}

function configure_rgs-em-pcsx2() {
    mkRomDir "ps2"

    moveConfigDir "$home/.config/PCSX2" "$md_conf_root/ps2/pcsx2"

    addEmulator 1 "$md_id-nogui" "ps2" "$md_inst/bin/PCSX2 %ROM% --fullscreen --nogui"
    addEmulator 0 "$md_id" "ps2" "$md_inst/bin/PCSX2 %ROM% --windowed"
    addSystem "ps2"
}
