#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-caprice32"
archrgs_module_desc="Amstrad CPC Emulator"
archrgs_module_help="ROM Extensions: .cdt .cpc .dsk\n\nCopy your Amstrad CPC games to $romdir/amstradcpc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/ColinPitrat/caprice32/master/COPYING.txt"
archrgs_module_section="emulators"

function install_bin_rgs-em-caprice32() {
    pacmanPkg rgs-em-caprice32
}

function remove_rgs-em-caprice32() {
    pacmanRemove rgs-em-caprice32
}

function configure_rgs-em-caprice32() {
    mkRomDir "amstradcpc"

    moveConfigDir "$home/.config/caprice32" "$md_conf_root/amstradcpc/caprice32"

    cp "$md_inst/share/caprice32/resources/cap32.cfg" "$md_conf_root/amstradcpc/caprice32/"
    chown "$user:$user" "$md_conf_root/amstradcpc/caprice32/cap32.cfg"

    local DIR=('cart' 'disk' 'snap' 'tape')
    for dir in "${DIR[@]}"; do
      #mkdir "$md_conf_root/amstradcpc/caprice32/$dir" && \
      #chown "$user:$user" "$md_conf_root/amstradcpc/caprice32/$dir" && \
      ln -s "$romdir/amstradcpc/" "$md_conf_root/amstradcpc/caprice32/$dir" 
    done
    
    addEmulator 1 "$md_id" "amstradcpc" "$md_inst/bin/cap32 %ROM%"
    addSystem "amstradcpc"
}
