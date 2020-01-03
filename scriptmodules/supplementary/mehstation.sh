#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution and
# at https://github.com/V0rt3x667/Arch-RetroGamingSystem/blob/master/LICENSE

archrgs_module_id="mehstation"
archrgs_module_desc="mehstation emulator frontend"
archrgs_module_licence="MIT https://raw.githubusercontent.com/remeh/mehstation/master/LICENSE"
archrgs_module_section="exp"
archrgs_module_flags="frontend"

function _get_database_mehstation() {
    echo "$configdir/all/mehstation/database.db"
}

function _add_system_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    command="${command//%ROM%/%exec%}"
    extensions="${extensions// /,}"
    NAME="$fullname" COMMAND="$command" DIR="$path" EXTS="$extensions" "/opt/archrgs/supplementary/mehstation/bin/mehtadata" -db="$db" -new-platform
}

function _del_system_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local fullname="$1"
    local name="$2"

    PLATFORM_NAME="$fullname" "/opt/archrgs/supplementary/mehstation/bin/mehtadata" -db="$db" -del-platform
}

function _add_rom_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local system_name="$1"
    local system_fullname="$2"
    local path="$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    NAME="$4" FILEPATH="$path" PLATFORM_NAME="$system_fullname" DESCRIPTION="$desc" "/opt/archrgs/supplementary/mehstation/bin/mehtadata" -db="$db" -new-exec

    RESOURCE="$image" FILEPATH="$path" PLATFORM_NAME="$system_fullname" TYPE="cover" "/opt/archrgs/supplementary/mehstation/bin/mehtadata" -db="$db" -new-res
}

function depends_mehstation() {
    local depends=(
                  cmake
                  automake
                  freeimage
                  openal
                  pango
                  libsndfile
                  alsa-lib
                  libjpeg-turbo
                  libtiff
                  libwebp
                  ffmpeg
                  sdl2
                  sdl2_ttf
                  sdl2_image
                  sqlite
                  go
                  )

    getDepends "${depends[@]}"
}

function sources_mehstation() {
    gitPullOrClone "$md_build" https://github.com/remeh/mehstation
    GOPATH="$md_build/mehtadata" go get github.com/remeh/mehtadata
}

function build_mehstation() {
    cd mehtadata
    GOPATH="$md_build/mehtadata" go build
    cd ..

    cmake .
    make clean
    make

    md_ret_require=(
        "$md_build/mehstation"
        "$md_build/mehtadata/bin/mehtadata"
    )
}

function install_mehstation() {
    mkdir -p "$md_inst"/{bin,share/mehstation}
    cp mehstation mehtadata/bin/mehtadata "$md_inst/bin/"
    cp -R res "$md_inst/share/"
}


function configure_mehstation() {
    # move / symlink the configuration
    moveConfigDir "$home/.config/mehstation" "$md_conf_root/all/mehstation"

    local db="$md_conf_root/all/mehstation/database.db"

    if [[ ! -f "$db" ]]; then
        local sql
        while read -r sql; do
            sudo -u $user SCHEMA="$sql" "$md_inst/bin/mehtadata" -db="$db" -init
        done < <(find "$md_inst/share/res" -name "*.sql" | sort)
    fi

    cat >/usr/bin/mehstation <<_EOF_
#!/bin/bash
pushd "$md_inst/share" >/dev/null
"$md_inst/bin/mehstation" "\$@"
popd
_EOF_
    chmod +x "/usr/bin/mehstation"

    local idx
    for idx in "${__mod_idx[@]}"; do
        if archrgs_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]] && ! hasFlag "${__mod_flags[$idx]}" "frontend"; then
            archrgs_callModule "$idx" configure
        fi
    done
}
