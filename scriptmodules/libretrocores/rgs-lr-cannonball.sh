#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-cannonball"
archrgs_module_desc="Cannonball - An Enhanced OutRun Engine"
archrgs_module_help="You need to unzip your OutRun set B from MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/cannonball/master/docs/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-cannonball() {
    pacmanPkg rgs-lr-cannonball
}

function remove_rgs-lr-cannonball() {
    pacmanRemove rgs-lr-cannonball
}

function configure_rgs-lr-cannonball() {
    setConfigRoot "ports"

    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "$md_inst/cannonball_libretro.so" "$romdir/ports/cannonball/outrun.game"

    mkRomDir "ports/cannonball"
	ensureSystemretroconfig "ports/cannonball"

    copyDefaultConfig "$md_inst/res/config.xml" "$md_conf_root/cannonball/config.xml"

    touch "$romdir/ports/cannonball/outrun.game"

    chown -R $user:$user  "$romdir/ports/cannonball"

    ln -s "$romdir/ports/cannonball" "$md_inst/roms"
}
