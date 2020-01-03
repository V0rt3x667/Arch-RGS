#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-mame"
archrgs_module_desc="MAME - Arcade Emulator - Latest Version."
archrgs_module_help="ROM Extensions: .zip .7z\n\nCopy your MAME roms to either $romdir/mame or\n$romdir/arcade"
archrgs_module_licence="GPL2 https://github.com/mamedev/mame/blob/master/LICENSE.md"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-mame() {
    pacmanPkg rgs-em-mame
}

function remove_rgs-em-mame() {
    pacmanRemove rgs-em-mame
}

function configure_rgs-em-mame() {
    local system="mame"

    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "$system"

        # Create required MAME directories underneath the ROM directory
        local mame_sub_dir
        for mame_sub_dir in artwork cfg comments diff inp nvram samples scores snap sta; do
            mkRomDir "$system/$mame_sub_dir"
        done

        # Create a BIOS directory, where people will be able to store their BIOS files, separate from ROMs
        mkUserDir "$biosdir/$system"

        # Create the configuration directory for the MAME ini files
        moveConfigDir "$home/.mame" "$md_conf_root/$system"

        # Create new INI files if they do not already exist
        # Create MAME config file
        local temp_ini_mame="$(mktemp)"

        iniConfig " " "" "$temp_ini_mame"
        iniSet "rompath"            "$romdir/$system;$romdir/arcade;$biosdir/$system"
        iniSet "hashpath"           "$md_inst/hash"
        iniSet "samplepath"         "$romdir/$system/samples;$romdir/arcade/samples"
        iniSet "artpath"            "$romdir/$system/artwork;$romdir/arcade/artwork"
        iniSet "ctrlrpath"          "$md_inst/ctrlr"
        iniSet "pluginspath"        "$md_inst/plugins"
        iniSet "languagepath"       "$md_inst/language"

        iniSet "cfg_directory"      "$romdir/$system/cfg"
        iniSet "nvram_directory"    "$romdir/$system/nvram"
        iniSet "input_directory"    "$romdir/$system/inp"
        iniSet "state_directory"    "$romdir/$system/sta"
        iniSet "snapshot_directory" "$romdir/$system/snap"
        iniSet "diff_directory"     "$romdir/$system/diff"
        iniSet "comment_directory"  "$romdir/$system/comments"

        iniSet "skip_gameinfo" "1"
        iniSet "plugin" "hiscore"
        iniSet "samplerate" "44100"

        # X86 Ubuntu by default uses OpenGL as a renderer, but SDL doesn't have target texture enabled as default.
		# Enabling accel will use target texture on X86 Ubuntu (and likely other X86 Linux platforms).
		iniSet "video" "accel"

        copyDefaultConfig "$temp_ini_mame" "$md_conf_root/$system/mame.ini"
        rm "$temp_ini_mame"

        # Create MAME UI config file
        local temp_ini_ui="$(mktemp)"
        iniConfig " " "" "$temp_ini_ui"
        iniSet "scores_directory" "$romdir/$system/scores"
        copyDefaultConfig "$temp_ini_ui" "$md_conf_root/$system/ui.ini"
        rm "$temp_ini_ui"

        # Create MAME Plugin config file
        local temp_ini_plugin="$(mktemp)"
        iniConfig " " "" "$temp_ini_plugin"
        iniSet "hiscore" "1"
        copyDefaultConfig "$temp_ini_plugin" "$md_conf_root/$system/plugin.ini"
        rm "$temp_ini_plugin"

        # Create MAME Hi Score config file
        local temp_ini_hiscore="$(mktemp)"
        iniConfig " " "" "$temp_ini_hiscore"
        iniSet "hi_path" "$romdir/$system/scores"
        copyDefaultConfig "$temp_ini_hiscore" "$md_conf_root/$system/hiscore.ini"
        rm "$temp_ini_hiscore"
    fi

    addEmulator 0 "$md_id" "arcade" "$md_inst/bin/mame %BASENAME%"
    addEmulator 1 "$md_id" "$system" "$md_inst/bin/mame %BASENAME%"

    addSystem "arcade"
    addSystem "$system"
}