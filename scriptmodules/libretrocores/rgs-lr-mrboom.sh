#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mrboom"
archrgs_module_desc="Mr.Boom - 8 players Bomberman clone for libretro."
archrgs_module_help="8 players Bomberman clone for libretro."
archrgs_module_licence="MIT https://raw.githubusercontent.com/libretro/mrboom-libretro/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mrboom() {
    pacmanPkg rgs-lr-mrboom
}

function remove_rgs-lr-mrboom() {
    pacmanRemove rgs-lr-mrboom
}

function configure_rgs-lr-mrboom() {
    setConfigRoot "ports"

    mkRomDir "ports/mrboom"

    addPort "$md_id" "mrboom" "Mr.Boom" "$md_inst/mrboom_libretro.so"

    ensureSystemretroconfig "ports/mrboom"
}
