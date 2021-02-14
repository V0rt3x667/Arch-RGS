#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-supertux"
archrgs_module_desc="SuperTux - Classic 2D Jump'n'Run Sidescroller Game"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/SuperTux/supertux/master/LICENSE.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-supertux() {
  pacmanPkg rgs-pt-supertux
}

function remove_rgs-pt-supertux() {
  pacmanRemove rgs-pt-supertux
}

function configure_rgs-pt-supertux() {
  addPort "$md_id" "supertux" "SuperTux" "$md_inst/bin/supertux2 --fullscreen"

  moveConfigDir $home/.local/share/supertux2 "$md_conf_root/supertux"
}
