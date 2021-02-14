#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-xrick"
archrgs_module_desc="Rick Dangerous Port"
archrgs_module_licence="CUSTOM  https://raw.githubusercontent.com/HerbFargus/xrick/master/README"
archrgs_module_section="ports"

function install_bin_rgs-pt-xrick() {
  pacmanPkg rgs-pt-xrick
}

function remove_rgs-pt-xrick() {
  pacmanRemove rgs-pt-xrick
}

function configure_rgs-pt-xrick() {
  addPort "$md_id" "xrick" "XRick" "$md_inst/bin/xrick -fullscreen"
}

