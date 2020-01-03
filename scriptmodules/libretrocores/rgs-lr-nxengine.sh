#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-nxengine"
archrgs_module_desc="Cave Story engine clone - NxEngine port for libretro"
archrgs_module_help="Copy the original Cave Story game files to $romdir/ports/CaveStory so you have the file $romdir/ports/CaveStory/Doukutsu.exe present."
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/nxengine-libretro/master/nxengine/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-nxengine() {
    pacmanPkg rgs-lr-nxengine
}

function remove_rgs-lr-nxengine() {
    pacmanRemove rgs-lr-nxengine
}

function configure_rgs-lr-nxengine() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "cavestory" "Cave Story" "$md_inst/nxengine_libretro.so"
    local file="$romdir/ports/Cave Story.sh"
    # custom launch script - if the data files are not found, warn the user
    cat >"$file" << _EOF_
#!/bin/bash
if [[ ! -f "$romdir/ports/CaveStory/Doukutsu.exe" ]]; then
    dialog --no-cancel --pause "$md_help" 22 76 15
else
    "$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ cavestory "$romdir/ports/CaveStory/Doukutsu.exe"
fi
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    ensureSystemretroconfig "ports/cavestory"
}