#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-micropolis"
archrgs_module_desc="Micropolis - Open Source City Building Game"
archrgs_module_licence="GPL https://raw.githubusercontent.com/SimHacker/micropolis/wiki/License.md"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-micropolis() {
    pacmanPkg rgs-pt-micropolis
}

function remove_rgs-pt-micropolis() {
    pacmanRemove rgs-pt-micropolis
}

function configure_rgs-pt-micropolis() {
    addPort "$md_id" "micropolis" "Micropolis" "$md_inst/bin/micropolis"
}
