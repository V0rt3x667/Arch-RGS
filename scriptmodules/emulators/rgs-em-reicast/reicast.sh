#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

ROM="$1"
rootdir="/opt/archrgs"
configdir="$rootdir/configs"
biosdir="$HOME/Arch-RGS/bios/dc"

source "$rootdir/lib/inifuncs.sh"

if [[ ! -f "$biosdir/dc_boot.bin" ]]; then
    dialog --no-cancel --pause "You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator." 22 76 15
    exit 1
fi

params=(
    -config config:homedir="$HOME" \
    -config x11:fullscreen=1 \
    -config audio:backend="pulse" \
    -config audio:disable=0
    )
[[ -n "$ROM" ]] && params+=(-config config:image="$ROM")
"$rootdir/emulators/rgs-em-reicast/bin/reicast" "${params[@]}"
