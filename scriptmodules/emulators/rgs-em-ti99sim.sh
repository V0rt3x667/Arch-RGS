#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-ti99sim"
archrgs_module_desc="TI-99/SIM - Texas Instruments Home Computer Emulator"
archrgs_module_help="ROM Extension: .ctg\n\nCopy your TI-99 games to $romdir/ti99\n\nCopy the required BIOS file TI-994A.ctg (case sensitive) to $biosdir"
archrgs_module_licence="GPL2 http://www.mrousseau.org/programs/ti99sim/"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-ti99sim() {
    pacmanPkg rgs-em-ti99sim
}

function remove_rgs-em-ti99sim() {
    pacmanRemove rgs-em-ti99sim
}

function configure_rgs-em-ti99sim() {
    mkRomDir "ti99"

    addEmulator 1 "$md_id" "ti99" "$md_inst/ti99sim.sh -f %ROM%"
    addSystem "ti99"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.ti99sim" "$md_conf_root/ti99/"
    ln -sf "$biosdir/TI-994A.ctg" "$md_inst/console/TI-994A.ctg"

    local file="$md_inst/bin/ti99sim.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst/bin"
./ti99sim-sdl "\$@"
popd
_EOF_
    chmod +x "$file"
}
