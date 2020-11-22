#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-digger"
archrgs_module_desc="Digger Remastered"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/sobomax/digger/master/README.md"
archrgs_module_section="ports"

function install_bin_rgs-pt-digger() {
  pacmanPkg rgs-pt-digger
}

function remove_rgs-pt-digger() {
  pacmanRemove rgs-pt-digger
}

function configure_rgs-pt-digger() {
  # remove symlink that isn't used
  #rm -f "$home/.config/digger"

  moveConfigFile "$home/.digger.rc" "$md_conf_root/digger/.digger.rc"
  moveConfigFile "$home/.digger.sco" "$md_conf_root/digger/.digger.sco"

  addPort "$md_id" "digger" "Digger Remastered" "$md_inst/bin/digger /F"
}

