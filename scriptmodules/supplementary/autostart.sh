#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="autostart"
archrgs_module_desc="Auto-start Emulation Station on boot"
archrgs_module_section="config"

function _update_hook_autostart() {
    if [[ -f /etc/profile.d/10-emulationstation.sh ]]; then
        enable_autostart
    fi
}

function _autostart_script_autostart() {
    local mode="$1"
    # delete old startup script
    rm -f /etc/profile.d/10-emulationstation.sh

    local script="$configdir/all/autostart.sh"

    cat >/etc/profile.d/10-retropie.sh <<_EOF_
# launch our autostart apps (if we are on the correct tty)
if [ "\`tty\`" = "/dev/tty1" ] && [ "\$USER" = "$user" ]; then
    bash "$script"
fi
_EOF_

    touch "$script"
    # delete any previous entries for emulationstation in autostart.sh
    sed -i '/#auto/d' "$script"
    # make sure there is a newline
    sed -i '$a\' "$script"
    echo "emulationstation #auto" >>"$script"
    chown $user:$user "$script"
}

function enable_autostart() {
    local mode="$1"
        mkUserDir "$home/.config/autostart"
        ln -sf "/usr/local/share/applications/Arch-RGS.desktop" "$home/.config/autostart/"
}

function disable_autostart() {
    local login_type="$1"
    [[ -z "$login_type" ]] && login_type="B2"
    rm "$home/.config/autostart/Arch-RGS.desktop"
}

function remove_autostart() {
    disable_autostart
}

function gui_autostart() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 76 16)
    while true; do
        if isPlatform "x86_64"; then
            local x11_autostart
            if [[ -f "$home/.config/autostart/archrgs.desktop" ]]; then
                options=(1 "Autostart Emulation Station after login (Enabled)")
                x11_autostart=1
            else
                options=(1 "Autostart Emulation Station after login (Disabled)")
                x11_autostart=0
            fi
        else
            options=(
                1 "Start Emulation Station at boot"
                E "Manually edit $configdir/autostart.sh"
            )

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    if isPlatform "x86_64"; then
                        if [[ "$x11_autostart" -eq 0 ]]; then
                            enable_autostart
                            printMsgs "dialog" "Emulation Station is set to autostart after login."
                        else
                            disable_autostart
                            printMsgs "dialog" "Autostarting of Emulation Station is disabled."
                        fi
                        x11_autostart=$((x11_autostart ^ 1))
                    fi
                    ;;
                E)
                    editFile "$configdir/all/autostart.sh"
                    ;;
                CL)
                    disable_autostart B1
                    printMsgs "dialog" "Booting to text console (require login)."
                    ;;
                CA)
                    disable_autostart B2
                    printMsgs "dialog" "Booting to text console (auto login as $user)."
                    ;;
                DL)
                    disable_autostart B3
                    printMsgs "dialog" "Booting to desktop (require login)."
                    ;;
                DA)
                    disable_autostart B4
                    printMsgs "dialog" "Booting to desktop (auto login as $user)."
                    ;;
            esac
        else
            break
        fi
    fi
    done
}
