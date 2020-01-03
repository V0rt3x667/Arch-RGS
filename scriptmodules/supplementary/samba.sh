#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution

archrgs_module_id="samba"
archrgs_module_desc="Configure Samba ROM Shares"
archrgs_module_section="config"

function depends_samba() {
    getDepends samba
}

function remove_share_samba() {
    local name="$1"
    [[ -z "$name" || ! -f /etc/samba/smb.conf ]] && return
    sed -i "/^\[$name\]/,/^force user/d" /etc/samba/smb.conf
}

function add_share_samba() {
    local name="$1"
    local path="$2"
    [[ -z "name" || -z "$path" ]] && return
    remove_share_samba "$name"
    cat >>/etc/samba/smb.conf <<_EOF_
[$1]
comment = $name
path = "$path"
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = $user
_EOF_
}

function restart_samba() {
    service samba restart || service smbd restart
}

function install_shares_samba() {
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    add_share_samba "roms" "$romdir"
    add_share_samba "bios" "$home/Arch-RGS/bios"
    add_share_samba "configs" "$configdir"
    add_share_samba "splashscreens" "$datadir/splashscreens"
    restart_samba
}

function remove_shares_samba() {
    local name
    for name in roms bios configs splashscreens; do
        remove_share_samba "$name"
    done
    restart_samba
}

function gui_samba() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Install Arch-RGS Samba shares"
            2 "Remove Arch-RGS Samba shares"
            3 "Manually edit /etc/samba/smb.conf"
            4 "Restart Samba service"
            5 "Remove Samba + configuration"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    archrgs_callModule "$md_id" depends
                    archrgs_callModule "$md_id" install_shares
                    printMsgs "dialog" "Installed and enabled shares"
                    ;;
                2)
                    archrgs_callModule "$md_id" remove_shares
                    printMsgs "dialog" "Removed shares"
                    ;;
                3)
                    editFile /etc/samba/smb.conf
                    ;;
                4)
                    archrgs_callModule "$md_id" restart
                    ;;
                5)
                    archrgs_callModule "$md_id" depends remove
                    printMsgs "dialog" "Removed Samba service"
                    ;;
            esac
        else
            break
        fi
    done
}
