#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-scummvm"
archrgs_module_desc="ScummVM - Virtual Machine for Graphical Point-and-Click Adventure Games"
archrgs_module_help="Copy Your ScummVM Games to $romdir/scummvm"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/scummvm/scummvm/master/COPYING"
archrgs_module_section="emulators"

function install_bin_rgs-em-scummvm() {
  pacmanPkg rgs-em-scummvm
}

function remove_rgs-em-scummvm() {
  pacmanRemove rgs-em-scummvm
}

function configure_rgs-em-scummvm() {
  mkRomDir "scummvm"

  local dir
  local name
  name="ScummVM"

  for dir in .config .local/share; do
    moveConfigDir "$home/$dir/scummvm" "$md_conf_root/scummvm"
  done

  ##Create Startup Script
  rm -f "$romdir/scummvm/+Launch GUI.sh"

  cat > "$romdir/scummvm/+Start $name.sh" << _EOF_
#!/usr/bin/env bash
game="\$1"
pushd "$romdir/scummvm" >/dev/null
$md_inst/bin/scummvm --fullscreen --joystick=0 --extrapath="$md_inst/share/scummvm" \$game
while read id desc; do
  echo "\$desc" > "$romdir/scummvm/\$id.svm"
done < <($md_inst/bin/scummvm --list-targets | tail -n +3)
popd >/dev/null
_EOF_
  chmod u+x "$romdir/scummvm/+Start $name.sh"
  chown "$user:$user" "$romdir/scummvm/+Start $name.sh"

  addEmulator 1 "$md_id" "scummvm" "bash $romdir/scummvm/+Start\ $name.sh %BASENAME%"
  addSystem "scummvm"
}

