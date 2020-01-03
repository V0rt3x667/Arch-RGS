#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-quasi88"
archrgs_module_desc="NEC PC-8801 emu - Quasi88 port for libretro"
archrgs_module_help="ROM Extensions: .d88 .88d .cmt .t88\n\nCopy your pc88 games to to $romdir/pc88\n\nCopy bios files n88.rom, n88_0.rom, n88_1.rom, n88_2.rom, n88_3.rom, n88n.rom, disk.rom, n88knj1.rom, n88knj2.rom, and n88jisho.rom to $biosdir/quasi88"
archrgs_module_licence="BSD https://raw.githubusercontent.com/libretro/quasi88-libretro/master/LICENSE"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-quasi88() {
    pacmanPkg rgs-lr-quasi88
}

function remove_rgs-lr-quasi88() {
    pacmanRemove rgs-lr-quasi88
}

function configure_rgs-lr-quasi88() {
    mkRomDir "pc88"
    ensureSystemretroconfig "pc88"
    addEmulator 1 "$md_id" "pc88" "$md_inst/quasi88_libretro.so"
    addSystem "pc88"
}
