#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-abuse"
archrgs_module_desc="Abuse SDL port originally from Crack-Dot-Com and released into the public domain."
archrgs_module_license="GPL https://raw.githubusercontent.com/Xenoveritas/abuse/master/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-abuse() {
   pacmanPkg rgs-pt-abuse
}

function remove_rgs-pt-abuse() {
   pacmanRemove rgs-pt-abuse
}

function configure_rgs-pt-abuse() {
    moveConfigDir "$home/.abuse" "$md_conf_root/abuse"

    addPort "$md_id" "abuse" "Abuse" "pushd $md_inst; $md_inst/bin/abuse -datadir $md_inst/data; popd"
}
