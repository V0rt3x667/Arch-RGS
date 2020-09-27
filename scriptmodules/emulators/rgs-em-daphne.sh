#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-daphne"
archrgs_module_desc="Daphne - Laserdisc Emulator"
archrgs_module_help="ROM Extension: .daphne\n\nCopy your Daphne roms to $romdir/daphne"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/DavidGriffith/daphne/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-daphne() {
    pacmanPkg rgs-em-daphne
}

function remove_rgs-em-daphne() {
    pacmanRemove rgs-em-daphne
}

function configure_rgs-em-daphne() {
    mkRomDir "daphne/roms"

    mkUserDir "$md_conf_root/daphne"

    moveConfigDir "$romdir/daphne/roms" "$md_inst/roms"

    if [[ "$md_mode" == "install" ]] && [[ ! -f "$md_conf_root/daphne/dapinput.ini" ]]; then
        cp -v "$md_inst/share/doc/dapinput.ini" "$md_conf_root/daphne/dapinput.ini"
        chown "$user":"$user" "$md_conf_root/daphne/dapinput.ini"    
    fi
    
    moveConfigFile "$md_conf_root/daphne/dapinput.ini" "$md_inst/dapinput.ini"
    
    addEmulator 1 "$md_id" "daphne" "$md_inst/bin/daphne.sh %ROM%"
    
    addSystem "daphne"

    [[ "$md_mode" == "remove" ]] && return

    cat >"$md_inst/bin/daphne.sh" <<_EOF_
#!/bin/bash
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

"$md_inst/bin/daphne" "\$name" vldp -framefile "\$dir/\$name.txt" -homedir "$md_inst" -fullscreen_window "\$params"
_EOF_
    chmod +x "$md_inst/bin/daphne.sh"
    
    #chown -R "$user:$user" "$md_inst"
    
}
