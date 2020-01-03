#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-jzintv"
archrgs_module_desc="Intellivision emulator"
archrgs_module_help="ROM Extensions: .int .bin\n\nCopy your Intellivision roms to $romdir/intellivision\n\nCopy the required BIOS files exec.bin and grom.bin to $biosdir"
archrgs_module_licence="GPL2 http://spatula-city.org/%7Eim14u2c/intv/"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-jzintv() {
    pacmanPkg rgs-em-jzintv
}

function remove_rgs-em-jzintv() {
    pacmanRemove rgs-em-jzintv
}

function configure_rgs-em-jzintv() {
    mkRomDir "intellivision"
    addEmulator 1 "$md_id" "intellivision" "$md_inst/bin/jzintv -p $biosdir -q %ROM%"
    addSystem "intellivision"
}
