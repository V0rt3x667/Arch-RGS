#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-hatari"
archrgs_module_desc="Atari emulator Hatari"
archrgs_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr .zip\n\nCopy your Atari ST games to $romdir/atarist\n\nCopy Atari ST BIOS (tos.img) to $biosdir"
archrgs_module_licence="GPL2 https://hg.tuxfamily.org/mercurialroot/hatari/hatari/file/9ee1235233e9/gpl.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-hatari() {
    pacmanPkg rgs-em-hatari
}

function remove_rgs-em-hatari() {
    pacmanRemove rgs-em-hatari
}

function configure_rgs-em-hatari() {
    mkRomDir "atarist"

    local common_config=("--confirm-quit 0" "--statusbar 0" "-f")

    addEmulator 1 "$md_id-fast" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 0 %ROM%"
    addEmulator 0 "$md_id-fast-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 1 %ROM%"
    addEmulator 0 "$md_id-compatible" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 0 %ROM%"
    addEmulator 0 "$md_id-compatible-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 1 %ROM%"
    addSystem "atarist"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    ln -sf "$biosdir/tos.img" "$md_inst/share/hatari/tos.img"
}
