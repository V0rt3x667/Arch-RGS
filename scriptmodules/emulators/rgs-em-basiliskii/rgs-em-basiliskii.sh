#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-basiliskii"
archrgs_module_desc="Apple Macintosh II Emulator"
archrgs_module_help="ROM Extensions: .img .rom\n\nCopy your Macintosh roms mac.rom and disk.img to $romdir/macintosh"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/cebix/macemu/master/BasiliskII/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-basiliskii() {
  pacmanPkg rgs-em-basiliskii
}

function remove_rgs-em-basiliskii() {
  pacmanRemove rgs-em-basiliskii
}

function configure_rgs-em-basiliskii() {
  mkRomDir "macintosh"
  mkUserDir "$md_conf_root/macintosh"

  addEmulator 1 "$md_id" "macintosh" "$md_inst/bin/BasiliskII --rom $romdir/macintosh/mac.rom --disk $romdir/macintosh/disk.img --extfs $romdir/macintosh --config $md_conf_root/macintosh/basiliskii.cfg"
  addSystem "macintosh"

  [[ "$md_mode" == "remove" ]] && return

  touch "$romdir/macintosh/Start.txt"
}

