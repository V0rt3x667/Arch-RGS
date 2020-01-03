#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-openmsx"
archrgs_module_desc="MSX emulator OpenMSX"
archrgs_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/openMSX/openMSX/master/doc/GPL.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-openmsx() {
    pacmanPkg rgs-em-openmsx
    
    mkdir -p "$md_inst/share/systemroms/"
    downloadAndExtract "$__archive_url/openmsxroms.tar.gz" "$md_inst/share/systemroms/"
}

function remove_rgs-em-openmsx() {
    pacmanRemove rgs-em-openmsx    
}

function configure_rgs-em-openmsx() {
    mkRomDir "msx"

    addEmulator 0 "$md_id" "msx" "$md_inst/bin/openmsx %ROM%"
    addSystem "msx"
}
