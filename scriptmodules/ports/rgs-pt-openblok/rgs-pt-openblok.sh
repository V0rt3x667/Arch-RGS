#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-openblok"
archrgs_module_desc="OpenBlok - A Block Dropping Game"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/openblok/master/LICENSE.md"
archrgs_module_section="ports"

function install_bin_rgs-pt-openblok {
  pacmanPkg rgs-pt-openblok
}

function remove_rgs-pt-openblok {
  pacmanRemove rgs-pt-openblok
}

function configure_rgs-pt-openblok() {
  moveConfigDir "$home/.local/share/openblok" "$md_conf_root/openblok"

  addPort "$md_id" "openblok" "OpenBlok" "$md_inst/openblok"
}

