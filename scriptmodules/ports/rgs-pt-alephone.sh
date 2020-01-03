#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-alephone"
archrgs_module_desc="AlephOne - Marathon Engine"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/Aleph-One-Marathon/alephone/master/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-alephone() {
    pacmanPkg rgs-pt-alephone
}

function remove_rgs-pt-alephone() {
    pacmanRemove rgs-pt-alephone
}

function game_data_rgs-pt-alephone() {
    local release_url="https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20180930"

    if [[ ! -f "$romdir/ports/alephone/Marathon/Shapes.shps" ]]; then
        downloadAndExtract "$release_url/Marathon-20180930-Data.zip" "$romdir/ports/alephone"
    fi

    if [[ ! -f "$romdir/ports/alephone/Marathon 2/Shapes.shpA" ]]; then
        downloadAndExtract "$release_url/Marathon2-20180930-Data.zip" "$romdir/ports/alephone"
    fi

    if [[ ! -f "$romdir/ports/alephone/Marathon Infinity/Shapes.shpA" ]]; then
        downloadAndExtract "$release_url/MarathonInfinity-20180930-Data.zip" "$romdir/ports/alephone"
    fi

    chown -R $user:$user "$romdir/ports/alephone"
}

function configure_rgs-pt-alephone() {
    addPort "$md_id" "marathon" "Aleph One Engine - Marathon" "'$md_inst/bin/alephone' '$romdir/ports/alephone/Marathon/'"
    addPort "$md_id" "marathon2" "Aleph One Engine - Marathon 2" "'$md_inst/bin/alephone' '$romdir/ports/alephone/Marathon 2/'"
    addPort "$md_id" "marathoninfinity" "Aleph One Engine - Marathon Infinity" "'$md_inst/bin/alephone' '$romdir/ports/alephone/Marathon Infinity/'"

    mkRomDir "ports/alephone"

    moveConfigDir "$home/.alephone" "$md_conf_root/alephone"
    # fix for wrong config location
    if [[ -d "/alephone" ]]; then
        cp -R /alephone "$md_conf_root/"
        rm -rf /alephone
        chown $user:$user "$md_conf_root/alephone"
    fi

    [[ "$md_mode" == "install" ]] && game_data_rgs-pt-alephone
}
