#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-residualvm"
archrgs_module_desc="ResidualVM - A 3D Game Interpreter"
archrgs_module_help="Copy your ResidualVM games to $romdir/residualvm"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/residualvm/residualvm/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-residualvm() {
    pacmanPkg rgs-em-residualvm
}

function remove_rgs-em-residualvm() {
    pacmanRemove rgs-em-residualvm
}

function configure_rgs-em-residualvm() {
    mkRomDir "residualvm"

    moveConfigDir "$home/.config/residualvm" "$md_conf_root/residualvm"

    # Create startup script
    cat > "$romdir/residualvm/+Start ResidualVM.sh" << _EOF_
#!/bin/bash
renderer="\$1"
[[ -z "\$renderer" ]] && renderer="software"
game="\$2"
[[ "\$game" =~ ^\+ ]] && game=""
pushd "$romdir/residualvm" >/dev/null
$md_inst/bin/residualvm --renderer=\$renderer --fullscreen --joystick=0 --extrapath="$md_inst/extra" \$game
while read id desc; do
    echo "\$desc" > "$romdir/residualvm/\$id.rvm"
done < <($md_inst/bin/residualvm --list-targets | tail -n +3)
popd >/dev/null
_EOF_
    chown "$user:$user" "$romdir/residualvm/+Start ResidualVM.sh"
    chmod u+x "$romdir/residualvm/+Start ResidualVM.sh"

    addEmulator 1 "$md_id" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh opengl_shaders %BASENAME%"
    addEmulator 0 "$md_id-software" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh software %BASENAME%"
    addSystem "residualvm" "ResidualVM" ".sh .rvm"
}
