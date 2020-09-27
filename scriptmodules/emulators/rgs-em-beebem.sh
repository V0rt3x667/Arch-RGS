#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-beebem"
archrgs_module_desc="BBC Micro & Master 128 Emulator"
archrgs_module_help="ROM Extension: .uef .ssd .dsd\n\nCopy your BBC Micro & Master 128 roms to $romdir/bbc"
archrgs_module_licence="OTHER"
archrgs_module_section="emulators"
archrgs_module_flbeebem="x86_64"

function install_bin_rgs-em-beebem() {
    pacmanPkg rgs-em-beebem
}

function remove_rgs-em-beebem() {
    pacmanRemove rgs-em-beebem
}

function configure_rgs-em-beebem() {
    mkRomDir "bbc"

    moveConfigDir "$home/.beebem" "$md_conf_root/bbc"

    addEmulator 1 "$md_id-modelb" "bbc" "$md_inst/bin/beebem -Model 0 %ROM%"
    addEmulator 0 "$md_id-b+integrab" "bbc" "$md_inst/bin/beebem -Model 1 %ROM%"
    addEmulator 0 "$md_id-bplus" "bbc" "$md_inst/bin/beebem -Model 2 %ROM%"
    addEmulator 0 "$md_id-master128" "bbc" "$md_inst/bin/beebem -Model 3 %ROM%"

    addSystem "bbc"
}
