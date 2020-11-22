#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-fe-pegasus-fe"
archrgs_module_desc="Pegasus - Cross Platform Customizable Graphical Frontend (Latest Alpha Release)"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
archrgs_module_section="exp"
archrgs_module_flags="frontend"

function install_bin_rgs-fe-pegasus-fe() {
  pacmanPkg rgs-fe-pegasus-fe
}

function remove_rgs-fe-pegasus-fe() {
  pacmanRemove rgs-fe-pegasus-fe
}

function configure_rgs-fe-pegasus-fe() {
  ##CREATE LAUNCHER SCRIPT
  cat >/usr/bin/pegasus-fe <<_EOF_
#!/bin/bash

  if [[ \$(id -u) -eq 0 ]]; then
    echo "Pegasus should not be run as root. If you used 'sudo pegasus-fe' please run without sudo."
    exit 1
  fi

##SAVE CURRENT TTY/VT NUMBER FOR USE WITH X SO IT CAN BE LAUNCHED ON THE CORRECT TTY
tty=\$(tty)
export TTY="\${tty:8:1}"

clear
"$md_inst/bin/pegasus-fe" "\$@"
_EOF_
  chmod +x /usr/bin/pegasus-fe

  moveConfigDir "$home/.config/pegasus-frontend" "$md_conf_root/all/pegasus-fe"

  mkUserDir "$md_conf_root/all/pegasus-fe/scripts"
  mkUserDir "$md_conf_root/all/pegasus-fe/themes"
}

