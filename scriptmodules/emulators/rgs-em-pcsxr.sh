#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-pcsxr"
archrgs_module_desc="Sony PlayStation emulator PCSX-Reloaded"
archrgs_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy your PSX roms to $romdir/psx\n\nCopy the required BIOS file SCPH1001.BIN to $biosdir"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/pcsxr/PCSX-Reloaded/master/pcsxr/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-pcsxr() {
    pacmanPkg rgs-em-pcsxr
}

function remove_rgs-em-pcsxr() {
    pacmanRemove rgs-em-pcsxr
}

function configure_rgs-em-pcsxr() {
    mkRomDir "psx"
    
    moveConfigDir "$home/.pcsxr" "$md_conf_root/psx/pcsxr"
    moveConfigDir "$biosdir" "$md_conf_root/psx/pcsxr/"
    moveConfigDir "$md_inst/lib" "$md_conf_root/psx/pcsxr/plugins"

    addEmulator 0 "$md_id-nogui" "psx" "$md_inst/bin/pcsxr -nogui -cdfile %ROM%"
    addEmulator 1 "$md_id" "psx" "$md_inst/bin/pcsxr -cdfile %ROM%"
    
    addSystem "psx"
}
