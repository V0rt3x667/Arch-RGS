#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-reicast"
archrgs_module_desc="Dreamcast emulator Reicast"
archrgs_module_help="ROM Extensions: .cdi .chd .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/reicast/reicast-emulator/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-reicast() {
    pacmanPkg rgs-em-reicast
}

function remove_rgs-em-reicast() {
    pacmanRemove rgs-em-reicast
}

function configure_rgs-em-reicast() {
    # copy hotkey remapping start script
    cp "$md_data/reicast.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/reicast.sh"

    mkRomDir "dreamcast"

    # move any old configs to the new location
    moveConfigDir "$home/.config/reicast" "$md_conf_root/dreamcast/"

    # Create home VMU, cfg, and data folders. Copy dc_boot.bin and dc_flash.bin to the ~/.reicast/data/ folder.
    mkdir -p "$md_conf_root/dreamcast/"{data,mappings}

    # symlink bios
    mkUserDir "$biosdir/dc"
    ln -sf "$biosdir/dc/"{dc_boot.bin,dc_flash.bin} "$md_conf_root/dreamcast/data"

    # copy default mappings
    cp "$md_inst/share/reicast/mappings/"*.cfg "$md_conf_root/dreamcast/mappings/"

    chown -R $user:$user "$md_conf_root/dreamcast"

    if [[ "$md_mode" == "install" ]]; then
        cat > "$romdir/dreamcast/+Start Reicast.sh" << _EOF_
#!/bin/bash
$md_inst/bin/reicast.sh
_EOF_
        chmod a+x "$romdir/dreamcast/+Start Reicast.sh"
        chown $user:$user "$romdir/dreamcast/+Start Reicast.sh"
    else
        rm "$romdir/dreamcast/+Start Reicast.sh"
    fi

    if [[ "$md_mode" == "install" ]]; then
        # possible audio backends: alsa, pulse
        backends=(alsa pulse)
	fi

    # add system(s)
    for backend in "${backends[@]}"; do
        addEmulator 1 "${md_id}-audio-${backend}" "dreamcast" "$md_inst/bin/reicast.sh $backend ${params[*]}"
    done
    addSystem "dreamcast"

    addAutoConf reicast_input 1
}

function input_rgs-em-reicast() {
    local temp_file="$(mktemp)"
    cd "$md_inst/bin"
    ./reicast-joyconfig -f "$temp_file" >/dev/tty
    iniConfig " = " "" "$temp_file"
    iniGet "mapping_name"
    local mapping_file="$configdir/dreamcast/mappings/evdev_${ini_value//[:><?\"]/-}.cfg"
    mv "$temp_file" "$mapping_file"
    chown $user:$user "$mapping_file"
}

function gui_rgs-em-reicast() {
    while true; do
        local options=(
            1 "Configure input devices for Reicast"
        )
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                clear
                input_rgs-em-reicast
                ;;
        esac
    done
}
