#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-xm7"
archrgs_module_desc="Fujitsu FM-7 series emulator"
archrgs_module_help="ROM Extensions: .d77 .t77 .d88 .2d \n\nCopy your FM-7 games to to $romdir/xm7\n\nCopy bios files DICROM.ROM, EXTSUB.ROM, FBASIC30.ROM, INITIATE.ROM, KANJI1.ROM, KANJI2.ROM, SUBSYS_A.ROM, SUBSYS_B.ROM, SUBSYSCG.ROM, SUBSYS_C.ROM, fddseek.wav, relayoff.wav and relay_on.wav to $biosdir/xm7"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/nakatamaho/XM7-for-SDL/master/Doc/mess/license.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-xm7() {
    pacmanPkg rgs-em-xm7
}

function remove_rgs-em-xm7() {
    pacmanRemove rgs-em-xm7
}

function configure_rgs-em-xm7() {
    mkRomDir "fm7"

    addEmulator 1 "$md_id" "fm7" "$md_inst/bin/xm7 %ROM%"
    addSystem "fm7"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.xm7" "$md_conf_root/fm7"

    mkUserDir "$biosdir/fm7"

    local bios
    for bios in DICROM.ROM EXTSUB.ROM FBASIC30.ROM INITIATE.ROM KANJI1.ROM KANJI2.ROM SUBSYS_A.ROM SUBSYS_B.ROM SUBSYSCG.ROM SUBSYS_C.ROM fddseek.wav relayoff.wav relay_on.wav; do
        ln -sf "$biosdir/fm7/$bios" "$md_conf_root/fm7/$bios"
    done
}
