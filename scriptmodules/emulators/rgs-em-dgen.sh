#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-dgen"
archrgs_module_desc="Megadrive/Genesis emulator DGEN"
archrgs_module_help="ROM Extensions: .32x .iso .cue .smd .bin .gen .md .sg .zip\n\nCopy your  Megadrive / Genesis roms to $romdir/megadrive\nSega 32X roms to $romdir/sega32x\nand SegaCD roms to $romdir/segacd\nThe Sega CD requires the BIOS files bios_CD_U.bin, bios_CD_E.bin, and bios_CD_J.bin copied to $biosdir"
archrgs_module_licence="GPL2 https://sourceforge.net/p/dgen/dgen/ci/master/tree/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-dgen() {
    pacmanPkg rgs-em-dgen
}

function remove_rgs-em-dgen() {
    pacmanRemove rgs-em-dgen
}

function configure_rgs-em-dgen() {
    local system
    for system in megadrive segacd sega32x; do
        mkRomDir "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/bin/dgen -f -r $md_conf_root/megadrive/dgenrc %ROM%"
        addSystem "$system"
    done

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.dgen" "$md_conf_root/megadrive"
    chown -R $user:$user "$md_conf_root/megadrive"

    if [[ ! -f "$md_conf_root/megadrive/dgenrc" ]]; then
        cp "$md_inst/share/docs/sample.dgenrc" "$md_conf_root/megadrive/dgenrc"
    fi

    iniConfig " = " "" "$md_conf_root/megadrive/dgenrc"

    iniSet "bool_fullscreen" "yes"
    iniSet "joy_pad1_a" "joystick0-button0"
    iniSet "joy_pad1_b" "joystick0-button1"
    iniSet "joy_pad1_c" "joystick0-button2"
    iniSet "joy_pad1_x" "joystick0-button3"
    iniSet "joy_pad1_y" "joystick0-button4"
    iniSet "joy_pad1_z" "joystick0-button5"
    iniSet "joy_pad1_mode" "joystick0-button6"
    iniSet "joy_pad1_start" "joystick0-button7"

    iniSet "joy_pad2_a" "joystick1-button0"
    iniSet "joy_pad2_b" "joystick1-button1"
    iniSet "joy_pad2_c" "joystick1-button2"
    iniSet "joy_pad2_x" "joystick1-button3"
    iniSet "joy_pad2_y" "joystick1-button4"
    iniSet "joy_pad2_z" "joystick1-button5"
    iniSet "joy_pad2_mode" "joystick1-button6"
    iniSet "joy_pad2_start" "joystick1-button7"
}
