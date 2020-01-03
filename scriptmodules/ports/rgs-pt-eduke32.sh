#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-eduke32"
archrgs_module_desc="Duke3D source port"
archrgs_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt?inline=false"
archrgs_module_section="ports"

function install_bin_rgs-pt-eduke32() {
    pacmanPkg rgs-pt-eduke32
}

function remove_rgs-pt-eduke32() {
    pacmanRemove rgs-pt-eduke32
}

function game_data_rgs-pt-eduke32() {
    cd "$_tmpdir"
    if [[ "$md_id" == "rgs-pt-eduke32" ]]; then
        if [[ ! -f "$romdir/ports/duke3d/duke3d.grp" ]]; then
            wget -O 3dduke13.zip "$__archive_url/3dduke13.zip"
            unzip -L -o 3dduke13.zip dn3dsw13.shr
            unzip -L -o dn3dsw13.shr -d "$romdir/ports/duke3d" duke3d.grp duke.rts
            rm 3dduke13.zip dn3dsw13.shr
            chown -R $user:$user "$romdir/ports/duke3d"
        fi
    fi
}

function configure_rgs-pt-eduke32() {
    local appname="eduke32"
    local portname="duke3d"
    if [[ "$md_id" == "rgs-pt-ionfury" ]]; then
        appname="fury"
        portname="ionfury"
    fi
    local config="$md_conf_root/$portname/settings.cfg"

    mkRomDir "ports/$portname"
    moveConfigDir "$home/.config/$appname" "$md_conf_root/$portname"

    add_games_rgs-pt-eduke32 "$portname" "$md_inst/bin/$appname"
    
     if [[ "$md_mode" == "install" ]]; then
        game_data_rgs-pt-eduke32

        touch "$config"
        iniConfig " " '"' "$config"

        # enforce vsync
        iniSet "r_swapinterval" "1"

        chown -R $user:$user "$config"
    fi
}

function add_games_rgs-pt-eduke32() {
    local portname="$1"
    local binary="$2"
    local game
    local game_args
    local game_path
    local game_launcher
    local num_games=4

    if [[ "$md_id" == "rgs-pt-ionfury" ]]; then
        num_games=0
        local game0=('Ion Fury' '' '')
    else
        local game0=('Duke Nukem 3D' '' '-addon 0')
        local game1=('Duke Nukem 3D - Duke It Out In DC' 'addons/dc' '-addon 1')
        local game2=('Duke Nukem 3D - Nuclear Winter' 'addons/nw' '-addon 2')
        local game3=('Duke Nukem 3D - Caribbean - Lifes A Beach' 'addons/vacation' '-addon 3')
        local game4=('NAM' 'addons/nam' '-nam')
    fi

    for ((game=0;game<=num_games;game++)); do
        game_launcher="game$game[0]"
        game_path="game$game[1]"
        game_args="game$game[2]"

        if [[ -d "$romdir/ports/$portname/${!game_path}" ]]; then
           addPort "$md_id" "$portname" "${!game_launcher}" "${binary}.sh %ROM%" "-j$romdir/ports/$portname/${game0[1]} -j$romdir/ports/$portname/${!game_path} ${!game_args}"
        fi
    done
    
    if [[ "$md_mode" == "install" ]]; then
        # we need to use a dumb launcher script to strip quotes from runcommand's generated arguments
        cat > "${binary}.sh" << _EOF_
#!/bin/bash

$binary \$*
_EOF_

        chmod +x "${binary}.sh"
    fi
}
