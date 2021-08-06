#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-ionfury"
archrgs_module_desc="Ion Fury - FPS Game Based On EDuke32 Source Port"
archrgs_module_help="Copy fury.def, fury.grp and fury.grpinfo to $romdir/ports/ionfury"
archrgs_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-ionfury() {
  pacmanPkg rgs-pt-ionfury
}

function remove_rgs-pt-ionfury() {
  pacmanRemove rgs-pt-ionfury
}

function configure_rgs-pt-ionfury() {
  configure_rgs-pt-eduke32
}

