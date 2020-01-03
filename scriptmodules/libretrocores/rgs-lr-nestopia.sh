#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-nestopia"
archrgs_module_desc="NES emu - Nestopia (enhanced) port for libretro"
archrgs_module_help="ROM Extensions: .nes .zip\n\nCopy your NES roms to $romdir/nes\n\nFor the Famicom Disk System copy your roms to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/nestopia/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-nestopia() {
    pacmanPkg rgs-lr-nestopia
}

function remove_rgs-lr-nestopia() {
    pacmanRemove rgs-lr-nestopia
}

function configure_rgs-lr-nestopia() {
    mkRomDir "nes"
    mkRomDir "fds"
    ensureSystemretroconfig "nes"
    ensureSystemretroconfig "fds"

    addEmulator 0 "$md_id" "nes" "$md_inst/nestopia_libretro.so"
    addEmulator 1 "$md_id" "fds" "$md_inst/nestopia_libretro.so"
    addSystem "nes"
    addSystem "fds"
}
