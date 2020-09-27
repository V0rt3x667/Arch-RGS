#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="resetromdirs"
archrgs_module_desc="Reset Ownership & Permissions of the Arch-RGS/roms Directory"
archrgs_module_section="config"

function gui_resetromdirs() {
    printHeading "Resetting $romdir ownershop/permissions"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    chown -R $user:$user "$romdir"
    chown -R $user:$user "$biosdir"
    chmod -R ug+rwX "$romdir"
    chmod -R ug+rwX "$biosdir"
}
