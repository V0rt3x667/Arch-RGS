#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-superflappybirds"
archrgs_module_desc="Super Flappy Birds - Multiplayer Flappy Bird Clone"
archrgs_module_help="https://github.com/IgniparousTempest/libretro-superflappybirds/wiki"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/IgniparousTempest/libretro-superflappybirds/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-superflappybirds() {
    pacmanPkg rgs-lr-superflappybirds
}

function remove_rgs-lr-superflappybirds() {
    pacmanRemove rgs-lr-superflappybirds
}

function configure_rgs-lr-superflappybirds() {
    setConfigRoot "ports"

    addPort "$md_id" "superflappybirds" "Super Flappy Birds" "$md_inst/superflappybirds_libretro.so"

    ensureSystemretroconfig "ports/superflappybirds"
}