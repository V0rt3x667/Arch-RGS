#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-ppsspp"
archrgs_module_desc="PlayStation Portable emu - PPSSPP port for libretro"
archrgs_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-ppsspp() {
    pacmanPkg rgs-lr-ppsspp
}

function remove_rgs-lr-ppsspp() {
    pacmanRemove rgs-lr-ppsspp
}

function configure_rgs-lr-ppsspp() {
    mkRomDir "psp"
    ensureSystemretroconfig "psp"

    if [[ "$md_mode" == "install_bin" ]]; then
        mkUserDir "$biosdir/PPSSPP"
        #cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
        #cp -Rv "$md_inst/flash0" "$biosdir/PPSSPP/"
        chown -R $user:$user "$biosdir/PPSSPP"
    fi

    addEmulator 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
    addSystem "psp"
}