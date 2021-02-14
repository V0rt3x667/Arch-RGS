#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-supertuxkart"
archrgs_module_desc="SuperTuxKart - 3D Kart Racing Game Featuring Tux & Friends"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/supertuxkart/stk-code/master/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-supertuxkart() {
  pacmanPkg rgs-pt-supertuxkart
}

function remove_rgs-pt-supertuxkart() {
  pacmanRemove rgs-pt-supertuxkart
}

function configure_rgs-pt-supertuxkart() {
  addPort "$md_id" "supertuxkart" "SuperTuxKart" "$md_inst/bin/supertuxkart -f"

  moveConfigDir $home/.local/share/supertuxkart "$md_conf_root/supertuxkart"
}
