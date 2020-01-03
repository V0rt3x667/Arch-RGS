#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-snes9x"
archrgs_module_desc="Super Nintendo emu - Snes9x (current) port for libretro"
archrgs_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-snes9x() {
    pacmanPkg rgs-lr-snes9x
}

function remove_rgs-lr-snes9x() {
    pacmanRemove rgs-lr-snes9x
}

function configure_rgs-lr-snes9x() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"
    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x_libretro.so"
    addSystem "snes"
}