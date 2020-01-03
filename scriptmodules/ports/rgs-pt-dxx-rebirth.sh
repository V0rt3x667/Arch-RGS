#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-dxx-rebirth"
archrgs_module_desc="DXX-Rebirth (Descent & Descent 2) build from source"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-dxx-rebirth() {
    pacmanPkg rgs-pt-dxx-rebirth
}

function remove_rgs-pt-dxx-rebirth() {
    pacmanRemove rgs-pt-dxx-rebirth
}

function game_data_rgs-pt-dxx-rebirth() {
    local D1X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
    local D2X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
    local D1X_HIGH_TEXTURE_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
    local D1X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
    local D2X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'

    cd "$__tmpdir"

    # Download / unpack / install Descent shareware files
    if [[ ! -f "$romdir/ports/descent1/descent.hog" ]]; then
        downloadAndExtract "$D1X_SHARE_URL" "$romdir/ports/descent1"
    fi

    # High Res Texture Pack
    if [[ ! -f "$romdir/ports/descent1/d1xr-hires.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_HIGH_TEXTURE_URL"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent1/d1xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_OGG_URL"
    fi

    # Download / unpack / install Descent 2 shareware files
    if [[ ! -f "$romdir/ports/descent2/D2DEMO.HOG" ]]; then
        downloadAndExtract "$D2X_SHARE_URL" "$romdir/ports/descent2"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent2/d2xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent2" "$D2X_OGG_URL"
    fi

    chown -R $user:$user "$romdir/ports/descent1" "$romdir/ports/descent2"
}

function configure_rgs-pt-dxx-rebirth() {
    local config
    local ver
    local name="Descent Rebirth"
    for ver in 1 2; do
        mkRomDir "ports/descent${ver}"
        [[ "$ver" -eq 2 ]] && name="Descent 2 Rebirth"
        addPort "$md_id" "descent${ver}" "$name" "$md_inst/bin/d${ver}x-rebirth -hogdir $romdir/ports/descent${ver}"

        # copy any existing configs from ~/.d1x-rebirth and symlink the config folder to $md_conf_root/descent1/
        moveConfigDir "$home/.d${ver}x-rebirth" "$md_conf_root/descent${ver}/"
        config="$md_conf_root/descent${ver}/descent.cfg"
        iniConfig "=" '' "$config"
        iniSet "VSync" "1"
        chown $user:$user "$config"
    done

    [[ "$md_mode" == "install" ]] && game_data_rgs-pt-dxx-rebirth
}
