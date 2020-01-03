#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mess2016"
archrgs_module_desc="MESS emulator - MESS Port for libretro"
archrgs_module_help="see wiki for detailed explanation"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame2016-libretro/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mess2016() {
    pacmanPkg rgs-lr-mess2016
}

function remove_rgs-lr-mess2016() {
    pacmanRemove rgs-lr-mess2016
}

function configure_rgs-lr-mess2016() {
    configure_rgs-lr-mess "mess2016_libretro.so"
}