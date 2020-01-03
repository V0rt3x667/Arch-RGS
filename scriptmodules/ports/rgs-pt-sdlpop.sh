#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-sdlpop"
archrgs_module_desc="SDLPoP - Port of Prince of Persia"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/NagyD/SDLPoP/master/doc/gpl-3.0.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-sdlpop() {
    pacmanPkg rgs-pt-sdlpop
}

function remove_rgs-pt-sdlpop() {
    pacmanRemove rgs-pt-sdlpop
}

function configure_rgs-pt-sdlpop() {
    addPort "$md_id" "sdlpop" "Prince of Persia" "pushd $md_inst; $md_inst/bin/prince full; popd"

    cp -v "$md_inst/bin/SDLPoP.ini" "$md_inst/bin/SDLPoP.ini.def"
    sed -i "s/use_correct_aspect_ratio = false/use_correct_aspect_ratio = true/" "$md_inst/bin/SDLPoP.ini.def"
    sed -i "s/start_fullscreen = false/start_fullscreen = true/" "$md_inst/bin/SDLPoP.ini.def"

    copyDefaultConfig "$md_inst/bin/SDLPoP.ini.def" "$md_conf_root/sdlpop/SDLPoP.ini"
    moveConfigFile "$md_inst/bin/SDLPoP.ini" "$md_conf_root/sdlpop/SDLPoP.ini"

    moveConfigFile "$md_inst/bin/PRINCE.SAV" "$md_conf_root/sdlpop/PRINCE.SAV"
    moveConfigFile "$md_inst/bin/QUICKSAVE.SAV" "$md_conf_root/sdlpop/QUICKSAVE.SAV"
    moveConfigFile "$md_inst/bin/SDLPoP.cfg" "$md_conf_root/sdlpop/SDLPoP.cfg"

    chown -R $user:$user "$md_conf_root/sdlpop"
}
