#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution and
# at https://github.com/V0rt3x667/Arch-RetroGamingSystem/blob/master/LICENSE

archrgs_module_id="steamcontroller"
archrgs_module_desc="Standalone Steam Controller Driver"
archrgs_module_help="Steam Controller Driver from https://github.com/ynsta/steamcontroller"
archrgs_module_licence="MIT https://raw.githubusercontent.com/ynsta/steamcontroller/master/LICENSE"
archrgs_module_section="driver"
archrgs_module_flags="noinstclean"

function depends_steamcontroller() {
    local depends=(
                  libusb
                  python 
                  python-virtualenv
                  )
    
    getDepends "${depends[@]}"
}

function sources_steamcontroller() {
    gitPullOrClone "$md_inst" https://github.com/ynsta/steamcontroller.git
}

function install_steamcontroller() {
    cd "$md_inst"
    chown -R "$user:$user"  "$md_inst"
    sudo -u $user bash -c "\
        virtualenv -p python --no-site-packages \"$md_inst\"; \
        source bin/activate; \
        python setup.py install; \
    "
}

function enable_steamcontroller() {
    local mode="$1"
    if [[ -n "$mode" ]]; then
        case "$mode" in
            xbox)
                    cp $scriptdir/scriptmodules/supplementary/steamcontroller/steamcontroller-xbox.service /usr/lib/systemd/system/ && \
                    sudo systemctl enable steamcontroller-xbox.service
                    ;;
            desktop)
                   cp $scriptdir/scriptmodules/supplementary/steamcontroller/steamcontroller-desktop.service /usr/lib/systemd/system/ && \
                    sudo systemctl enable steamcontroller-desktop.service
                    ;;
        esac
    fi
        
local config="\"$md_inst/bin/sc-$mode.py\" start"

printMsgs "dialog" "$md_id enabled in /usr/lib/systemd/system/ with the following config:\n\n$config\n\nThe service will be started on next boot."
}

function disable_steamcontroller() {
    local service=$(systemctl list-unit-files | grep steamcontroller | grep -w "$1") 

    sudo systemctl disable $service
}

function remove_steamcontroller() {
    disable_steamcontroller
    rm -f /etc/udev/rules.d/99-steam-controller.rules
}

function configure_steamcontroller() {
    cat >/etc/udev/rules.d/99-steam-controller.rules <<\_EOF_
# Steam controller keyboard/mouse mode
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="input", MODE="0660"

# Steam controller gamepad mode
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
_EOF_
}

function gui_steamcontroller() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable steamcontroller (xbox 360 mode)"
        2 "Enable steamcontroller (desktop mouse/keyboard mode)"
        3 "Disable steamcontroller"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    enable_steamcontroller xbox
                    ;;
                2)
                    enable_steamcontroller desktop
                    ;;
                3)
                    disable_steamcontroller
                    printMsgs "dialog" "steamcontroller removed from /usr/lib/systemd/system/"
                    ;;
             esac
        else
            break
        fi
    done
}
