#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-uhexen2"
archrgs_module_desc="Hexen II source port"
archrgs_module_licence="GPL2 https://sourceforge.net/projects/uhexen2/"
archrgs_module_help="For the registered version, please add your full version PAK files to $romdir/ports/hexen2/data1/ to play. These files for the registered version are required: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-uhexen2() {
    pacmanPkg rgs-pt-uhexen2
}

function remove_rgs-pt-uhexen2() {
    pacmanRemove rgs-pt-uhexen2
}

function game_data_rgs-pt-uhexen2() {
    if [[ ! -f "$romdir/ports/hexen2/data1/pak0.pak" ]]; then
        downloadAndExtract "https://netix.dl.sourceforge.net/project/uhexen2/Hexen2Demo-Nov.1997/hexen2demo_nov1997-linux-i586.tgz" "$romdir/ports/hexen2" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R $user:$user "$romdir/ports/hexen2/data1"
    fi
}

function configure_rgs-pt-uhexen2() {
    addPort "$md_id" "hexen2" "Hexen II" "$md_inst/bin/glhexen2"

    mkRomDir "ports/hexen2"

    moveConfigDir "$home/.hexen2" "$romdir/ports/hexen2"

    [[ "$md_mode" == "install" ]] && game_data_rgs-pt-uhexen2
}
