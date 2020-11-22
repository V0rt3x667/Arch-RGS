#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-lincity-ng"
archrgs_module_desc="Lincity-NG - Open Source City Building Game"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/lincity-ng/lincity-ng/master/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-lincity-ng() {
  pacmanPkg rgs-pt-lincity-ng
}

function remove_rgs-pt-lincity-ng() {
  pacmanRemove rgs-pt-lincity-ng
}

function configure_rgs-pt-lincity-ng() {
  addPort "$md_id" "lincity-ng" "LinCity-NG" "$md_inst/bin/lincity-ng"

  moveConfigDir "$home/.lincity-ng" "$md_conf_root/lincity-ng"
}

