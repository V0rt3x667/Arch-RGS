#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-atari800"
archrgs_module_desc="Atari 8-bit/800/5200 emulator"
archrgs_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopy your Atari800 games to $romdir/atari800\n\nCopy your Atari 5200 roms to $romdir/atari5200 You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir and then on first launch configure it to scan that folder for roms (F1 -> Emulator Configuration -> System Rom Settings)"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/atari800/atari800/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-atari800() {
    pacmanPkg rgs-em-atari800
}

function remove_rgs-em-atari800() {
    pacmanRemove rgs-em-atari800
}

function configure_rgs-em-atari800() {
    mkRomDir "atari800"
    mkRomDir "atari5200"

    [[ "$md_mode" == "install" ]]

    mkUserDir "$md_conf_root/atari800"

    moveConfigFile "$home/.atari800.cfg" "$md_conf_root/atari800/atari800.cfg"

    iniConfig " = " "" "$md_conf_root/atari800/atari800.cfg"
    iniSet "SDL_JOY_0_ENABLED" "1"
    iniSet "SDL_JOY_0_LEFT" "260"
    iniSet "SDL_JOY_0_RIGHT" "262"
    iniSet "SDL_JOY_0_UP" "264"
    iniSet "SDL_JOY_0_DOWN" "261"
    iniSet "SDL_JOY_0_TRIGGER" "305"
    iniSet "SDL_JOY_1_ENABLED" "0"
    iniSet "SDL_JOY_1_LEFT" "97"
    iniSet "SDL_JOY_1_RIGHT" "100"
    iniSet "SDL_JOY_1_UP" "119"
    iniSet "SDL_JOY_1_DOWN" "115"
    iniSet "SDL_JOY_1_TRIGGER" "306"

    # copy launch script (used for unpacking archives)
    cp "$md_data/atari800.sh" "$md_inst"
    chmod +x "$md_inst/atari800.sh"

    addEmulator 0 "atari800-800-pal" "atari800" "$md_inst/atari800.sh %ROM% Atari800-PAL"
    addEmulator 1 "atari800-800-ntsc" "atari800" "$md_inst/atari800.sh %ROM% Atari800-NTSC"
    addEmulator 1 "atari800-800xl" "atari800" "$md_inst/atari800.sh %ROM% Atari800XL"
    addEmulator 1 "atari800-130xe" "atari800" "$md_inst/atari800.sh %ROM% Atari130XE"
    addEmulator 1 "atari800-5200" "atari5200" "$md_inst/atari800.sh %ROM% Atari5200"
    addSystem "atari800"
    addSystem "atari5200"
}
