#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-oricutron"
archrgs_module_desc="Oricutron Oric 1/Oric Atmos emulator"
archrgs_module_help="ROM Extensions: .dsk .tap\n\nCopy your Oric games to $romdir/oric"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/pete-gordon/oricutron/4c359acfb6bd36d44e6d37891d7b6453324faf7d/main.h"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-oricutron() {
    pacmanPkg rgs-em-oricutron
}

function remove_rgs-em-oricutron() {
    pacmanRemove rgs-em-oricutron
}

function game_data_rgs-em-oricutron() {
    if [[ -d "$md_inst/disks" && ! -f "$romdir/oric/barbitoric.dsk" ]]; then
        # copy demo disks
        cp -v "$md_inst/disks/"* "$romdir/oric/"
        chown -R $user:$user "$romdir/oric"
    fi
}

function configure_rgs-em-oricutron() {
    mkRomDir "oric"

    local machine
    local default
    for machine in atmos oric1 o16k telestrat pravetz; do
        default=0
        [[ "$machine" == "atmos" ]] && default=1
        addEmulator "$default" "$md_id-$machine" "oric" "pushd $md_inst; $md_inst/bin/oricutron --machine $machine %ROM% --fullscreen; popd"
    done
    addSystem "oric"

    [[ "$md_mode" == "install" ]] && game_data_oricutron
}
