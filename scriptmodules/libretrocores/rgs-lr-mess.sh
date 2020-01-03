#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mess"
archrgs_module_desc="MESS emulator - MESS Port for libretro"
archrgs_module_help="see wiki for detailed explanation"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mess() {
    pacmanPkg rgs-lr-mess
}

function remove_rgs-lr-mess() {    
    pacmanRemove rgs-lr-mess
}

function configure_rgs-lr-mess() {
    local module="$1"
    [[ -z "$module" ]] && module="mess_libretro.so"

    local system
    for system in nes gb coleco arcadia crvision; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/$module"
        addSystem "$system"
    done

    setRetroArchCoreOption "mame_softlists_enable" "enabled"
    setRetroArchCoreOption "mame_softlists_auto_media" "enabled"
    setRetroArchCoreOption "mame_boot_from_cli" "enabled"

    mkdir "$biosdir/mame"
    cp -rv "$md_build/hash" "$biosdir/mame/"
    chown -R $user:$user "$biosdir/mame"
}