#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-simcoupe"
archrgs_module_desc="SimCoupe SAM Coupe emulator"
archrgs_module_help="ROM Extensions: .dsk .mgt .sbt .sad\n\nCopy your SAM Coupe games to $romdir/samcoupe."
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/simonowen/simcoupe/master/License.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-simcoupe() {
    pacmanPkg rgs-em-simcoupe
}

function remove_rgs-em-simcoupe() {
    pacmanRemove rgs-em-simcoupe
}

function configure_rgs-em-simcoupe() {
    mkRomDir "samcoupe"
    moveConfigDir "$home/.simcoupe" "$md_conf_root/simcoupe"

    addEmulator 1 "$md_id" "samcoupe" "pushd $md_inst; $md_inst/bin/simcoupe autoboot -disk1 %ROM% -fullscreen; popd"
    addSystem "samcoupe"
}
