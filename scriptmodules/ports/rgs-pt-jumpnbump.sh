#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-jumpnbump"
archrgs_module_desc="Jump 'n Bump, play cute bunnies jumping on each other's heads - Modernization fork"
archrgs_module_help="Copy custom game levels (.dat) to $romdir/ports/jumpnbump"
archrgs_module_licence="GPL2 https://gitlab.com/LibreGames/jumpnbump/raw/master/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-jumpnbump() {
    pacmanPkg rgs-pt-jumpnbump
}

function remove_rgs-pt-jumpnbump() {
    pacmanRemove rgs-pt-jumpnbump
}

function game_data_rgs-pt-jumpnbump() {
    local tmpdir="$(mktemp -d)"
    local compressed
    local uncompressed

    # install extra levels from Debian's jumpnbump-levels package
    downloadAndExtract "https://salsa.debian.org/games-team/jumpnbump-levels/-/archive/master/jumpnbump-levels-master.tar.bz2" "$tmpdir" --strip-components 1 --wildcards "*.bz2"
    for compressed in "$tmpdir"/*.bz2; do
        uncompressed="${compressed##*/}"
        uncompressed="${uncompressed%.bz2}"
        if [[ ! -f "$romdir/ports/jumpnbump/$uncompressed" ]]; then
            bzcat "$compressed" > "$romdir/ports/jumpnbump/$uncompressed"
            chown -R $user:$user "$romdir/ports/jumpnbump/$uncompressed"
        fi
    done
    rm -rf "$tmpdir"
}

function configure_rgs-pt-jumpnbump() {
    addPort "$md_id" "jumpnbump" "Jump 'n Bump" "$md_inst/data/jumpnbump.sh"
    mkRomDir "ports/jumpnbump"
    [[ "$md_mode" == "remove" ]] && return

    # install game data
    game_data_rgs-pt-jumpnbump

    # install launch script
    #cp "$md_inst/data/jumpnbump.sh" "$md_inst"
    iniConfig "=" '"' "$md_inst/data/jumpnbump.sh"
    iniSet "ROOTDIR" "$rootdir"
    iniSet "MD_CONF_ROOT" "$md_conf_root"
    iniSet "ROMDIR" "$romdir"
    iniSet "MD_INST" "$md_inst"

    # set default game options on first install
    if [[ ! -f "$md_conf_root/jumpnbump/options.cfg" ]];  then
        iniConfig " = " "" "$md_conf_root/jumpnbump/options.cfg"
        iniSet "nogore" "1"
    fi
}
