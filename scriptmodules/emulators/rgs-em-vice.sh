#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-vice"
archrgs_module_desc="C64 emulator VICE"
archrgs_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .x64 .zip .vsf\n\nCopy your Commodore 64 games to $romdir/c64"
archrgs_module_licence="GPL2 http://svn.code.sf.net/p/vice-emu/code/trunk/vice/COPYING"
archrgs_module_section="emulators"

function install_bin_rgs-em-vice() {
    pacmanPkg rgs-em-vice
}

function remove_rgs-em-vice() {
    pacmanRemove rgs-em-vice
}

function configure_rgs-em-vice() {
    # get a list of supported extensions
    local exts="$(getPlatformConfig c64_exts)"

    # install the vice start script
    mkdir -p "$md_inst/bin"
    cat > "$md_inst/bin/vice.sh" << _EOF_
#!/bin/bash

BIN="\${0%/*}/\$1"
ROM="\$2"
PARAMS=("\${@:3}")

romdir="\${ROM%/*}"
ext="\${ROM##*.}"
source "$rootdir/lib/archivefuncs.sh"

archiveExtract "\$ROM" "$exts"

# check successful extraction and if we have at least one file
if [[ \$? == 0 ]]; then
    ROM="\${arch_files[0]}"
    romdir="\$arch_dir"
fi

"\$BIN" -chdir "\$romdir" "\${PARAMS[@]}" "\$ROM"
archiveCleanup
_EOF_

    chmod +x "$md_inst/bin/vice.sh"

    mkRomDir "c64"

    addEmulator 1 "$md_id-x64" "c64" "$md_inst/bin/vice.sh x64 %ROM%"
    addEmulator 0 "$md_id-x64sc" "c64" "$md_inst/bin/vice.sh x64sc %ROM%"
    addEmulator 0 "$md_id-x128" "c64" "$md_inst/bin/vice.sh x128 %ROM%"
    addEmulator 0 "$md_id-xpet" "c64" "$md_inst/bin/vice.sh xpet %ROM%"
    addEmulator 0 "$md_id-xplus4" "c64" "$md_inst/bin/vice.sh xplus4 %ROM%"
    addEmulator 0 "$md_id-xvic" "c64" "$md_inst/bin/vice.sh xvic %ROM%"
    addEmulator 0 "$md_id-xvic-cart" "c64" "$md_inst/bin/vice.sh xvic %ROM% -cartgeneric"
    addSystem "c64"

    [[ "$md_mode" == "remove" ]] && return

    # copy configs and symlink the old and new config folders to $md_conf_root/c64/
    moveConfigDir "$home/.vice" "$md_conf_root/c64"
    moveConfigDir "$home/.config/vice" "$md_conf_root/c64"

    local config="$(mktemp)"
    echo "[C64]" > "$config"
    iniConfig "=" "" "$config"
    iniSet "VICIIFullscreen" "1"

    copyDefaultConfig "$config" "$md_conf_root/c64/sdl-vicerc"
    rm "$config"
}
