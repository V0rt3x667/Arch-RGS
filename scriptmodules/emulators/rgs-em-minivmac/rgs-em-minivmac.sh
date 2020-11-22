#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-minivmac"
archrgs_module_desc="Mini vMac - Apple Macintosh Plus Emulator"
archrgs_module_help="ROM Extensions: .dsk \n\nCopy your Macintosh Plus disks to $romdir/macintosh \n\n You need to copy the Macintosh bios file vMac.ROM into $biosdir and System Tools.dsk to $romdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/vanfanel/minivmac_sdl2/master/COPYING.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-minivmac() {
  pacmanPkg rgs-em-minivmac
}

function remove_rgs-em-minivmac() {
  pacmanRemove rgs-em-minivmac
}

function configure_rgs-em-minivmac() {
  mkRomDir "macintosh"

  ln -sf "$biosdir/vMac.ROM" "$md_inst/vMac.ROM"

  addEmulator 1 "$md_id" "macintosh" "pushd $md_inst; $md_inst/minivmac $romdir/macintosh/System\ Tools.dsk %ROM%; popd"
  addSystem "macintosh"
}

