#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-giana"
archrgs_module_desc="Giana's Return Unofficial Sequel to the Mario Clone Great Giana Sisters"
archrgs_module_licence="NONCOM https://www.gianas-return.de/?page_id=6"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-giana() {
  pacmanPkg rgs-pt-giana
}

function install_remove_rgs-pt-giana() {
  pacmanRemove rgs-pt-giana
}

function configure_rgs-pt-giana() {
  moveConfigDir "$home/.giana" "$md_conf_root/giana"

  addPort "$md_id" "giana" "Giana's Return" "pushd $md_inst; $md_inst/bin/giana_linux64 -fs -a44; popd"
}

