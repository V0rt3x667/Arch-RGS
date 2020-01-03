#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-scummvm"
archrgs_module_desc="ScummVM port for libretro"
archrgs_module_help="Copy your ScummVM games to $romdir/scummvm\n\nThe name of your game directories must be suffixed with '.svm' for direct launch in EmulationStation."
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/scummvm/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-scummvm() {
    pacmanPkg rgs-lr-scummvm
}

function remove_rgs-lr-scummvm() {
    pacmanRemove rgs-lr-scummvm
}

function configure_rgs-lr-scummvm() {
    addEmulator 0 "$md_id" "scummvm" "$md_inst/romdir-launcher.sh %ROM%"
    addSystem "scummvm"
    [[ "$md_mode" == "remove" ]] && return

    # ensure rom dir and system retroconfig
    mkRomDir "scummvm"
    ensureSystemretroconfig "scummvm"

    # download and extract auxiliary data (theme, extra)
    downloadAndExtract "https://github.com/libretro/scummvm/raw/master/backends/platform/libretro/aux-data/scummvm.zip" "$biosdir"
    chown -R $user:$user "$biosdir/scummvm"

    # basic initial configuration (if config file not found)
    if [[ ! -f "$biosdir/scummvm.ini" ]]; then
        echo "[scummvm]" > "$biosdir/scummvm.ini"
        iniConfig "=" "" "$biosdir/scummvm.ini"
        iniSet "extrapath" "$biosdir/scummvm/extra"
        iniSet "themepath" "$biosdir/scummvm/theme"
        iniSet "soundfont" "$biosdir/scummvm/extra/Roland_SC-55.sf2"
        iniSet "gui_theme" "scummmodern"
        iniSet "subtitles" "true"
        iniSet "multi_midi" "true"
        iniSet "gm_device" "fluidsynth"
        chown $user:$user "$biosdir/scummvm.ini"
    fi

    # create retroarch launcher for rgs-lr-scummvm with support for rom directories
    # containing svm files inside (for direct game directory launching in ES)
    cat > "$md_inst/romdir-launcher.sh" << _EOF_
#!/usr/bin/env bash
ROM=\$1; shift
SVM_FILES=()
[[ -d \$ROM ]] && mapfile -t SVM_FILES < <(compgen -G "\$ROM/*.svm")
[[ \${#SVM_FILES[@]} -eq 1 ]] && ROM=\${SVM_FILES[0]}
$emudir/retroarch/bin/retroarch \\
    -L "$md_inst/scummvm_libretro.so" \\
    --config "$md_conf_root/scummvm/retroarch.cfg" \\
    "\$ROM" "\$@"
_EOF_
    chmod +x "$md_inst/romdir-launcher.sh"
}