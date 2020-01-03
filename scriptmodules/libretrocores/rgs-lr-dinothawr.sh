#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-dinothawr"
archrgs_module_desc="Dinothawr - standalone libretro puzzle game"
archrgs_module_help="Dinothawr game assets are automatically installed to $romdir/ports/dinothawr/"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Dinothawr/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-dinothawr() {
    pacmanPkg rgs-lr-dinothawr
}

function remove_rgs-lr-dinothawr() {
    pacmanRemove rgs-lr-dinothawr
}

function configure_rgs-lr-dinothawr() {
    setConfigRoot "ports"

    addPort "$md_id" "dinothawr" "Dinothawr" "$md_inst/dinothawr_libretro.so" "$romdir/ports/dinothawr/dinothawr.game"

    mkRomDir "ports/dinothawr"
    ensureSystemretroconfig "ports/dinothawr"

    cp -Rv "$md_inst/dinothawr" "$romdir/ports"

    chown $user:$user -R "$romdir/ports/dinothawr"
}