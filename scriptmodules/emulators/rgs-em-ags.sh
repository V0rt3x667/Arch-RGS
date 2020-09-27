#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-ags"
archrgs_module_desc="Adventure Game Studio - Adventure game engine"
archrgs_module_help="ROM Extension: .exe\n\nCopy your Adventure Game Studio roms to $romdir/ags"
archrgs_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-ags() {
    pacman -U \
      https://archive.archlinux.org/packages/d/dumb-a4/dumb-a4-2.0.3-1-x86_64.pkg.tar.xz --needed --noconfirm && \
    pacmanPkg rgs-em-ags
}

function remove_rgs-em-ags() {
    pacmanRemove rgs-em-ags
}

function configure_rgs-em-ags() {
    mkRomDir "ags"

    addEmulator 1 "$md_id" "ags" "$md_inst/bin/ags --fullscreen %ROM%" "Adventure Game Studio" ".exe"
    
    addSystem "ags"
}
