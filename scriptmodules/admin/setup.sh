#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="setup"
archrgs_module_desc="GUI based setup for Arch-RGS"
archrgs_module_section=""

function _setup_gzip_log() {
    setsid tee >(setsid gzip --stdout >"$1")
}

function archrgs_logInit() {
    if [[ ! -d "$__logdir" ]]; then
        if mkdir -p "$__logdir"; then
            chown $user:$user "$__logdir"
        else
            fatalError "Couldn't make directory $__logdir"
        fi
    fi
    local now=$(date +'%Y-%m-%d_%H%M%S')
    logfilename="$__logdir/archrgs_$now.log.gz"
    touch "$logfilename"
    chown $user:$user "$logfilename"
    time_start=$(date +"%s")
}

function archrgs_logStart() {
    echo -e "Log started at: $(date -d @$time_start)\n"
    echo "Arch-RGS Setup version: $__version ($(git -C "$scriptdir" log -1 --pretty=format:%h))"
    echo "System: $__os_desc - $(uname -a)"
}

function archrgs_logEnd() {
    time_end=$(date +"%s")
    echo
    echo "Log ended at: $(date -d @$time_end)"
    date_total=$((time_end-time_start))
    local hours=$((date_total / 60 / 60 % 24))
    local mins=$((date_total / 60 % 60))
    local secs=$((date_total % 60))
    echo "Total running time: $hours hours, $mins mins, $secs secs"
}

function archrgs_printInfo() {
    reset
    if [[ ${#__ERRMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__ERRMSGS[@]}"
        printMsgs "dialog" "Please see $1 for more in depth information regarding the errors."
    fi
    if [[ ${#__INFMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__INFMSGS[@]}"
    fi
    __ERRMSGS=()
    __INFMSGS=()
}

function depends_setup() {
    # Check for VERSION file.
    if [[ ! -f "$rootdir/VERSION" ]]; then
        joy2keyStop
        exec "$scriptdir/archrgs_packages.sh" setup post_update gui_setup
    fi

    # Remove all but the last 20 logs.
    find "$__logdir" -type f | sort | head -n -20 | xargs -d '\n' --no-run-if-empty rm
}

function updatescript_setup() {
    clear
    chown -R $user:$user "$scriptdir"
    printHeading "Fetching latest version of the Arch-RGS Setup Script."
    pushd "$scriptdir" >/dev/null
    if [[ ! -d ".git" ]]; then
        printMsgs "dialog" "Cannot find directory '.git'. Please clone the Arch-RGS Setup script via 'git clone https://gitlab.com/arch-rgs/arch-rgs.git'"
        popd >/dev/null
        return 1
    fi
    local error
    if ! error=$(su $user -c "git pull 2>&1 >/dev/null"); then
        printMsgs "dialog" "Update failed:\n\n$error"
        popd >/dev/null
        return 1
    fi
    popd >/dev/null

    printMsgs "dialog" "Fetched the latest version of the Arch-RGS Setup script."
    return 0
}

function post_update_setup() {
    local return_func=("$@")

    joy2keyStart

    echo "$__version" >"$rootdir/VERSION"

    clear
    local logfilename
    archrgs_logInit
    {
        archrgs_logStart
        printHeading "Running post update hooks"
        archrgs_updateHooks
        archrgs_logEnd
    } &> >(_setup_gzip_log "$logfilename")
    archrgs_printInfo "$logfilename"

    printMsgs "dialog" "NOTICE: The Arch-RGS setup script is available to download for free from:\n\nhttps://gitlab.com/arch-rgs/arch-rgs.git.\n\nArch-RGS includes software that has non commercial licences. Selling or including Arch-RGS with your commercial product is not allowed.\n\nNo copyrighted games are included with Arch-RGS.\n\nIf you have been sold this software, you can report it by emailing archrgs_project@gmail.com."

    # return to set return function
    "${return_func[@]}"
}

function package_setup() {
    local idx="$1"
    local md_id="${__mod_id[$idx]}"

    while true; do
        local options=()

        local install
        local status
        if archrgs_isInstalled "$idx"; then
            install="Update"
            status="Installed"
        else
            install="Install"
            status="Not installed"
        fi

        if archrgs_hasPackage "$idx"; then
            options+=(I "$install from package")
        fi

        if fnExists "sources_${md_id}"; then
            options+=(S "$install from source")
        fi

        if archrgs_isInstalled "$idx"; then
            if fnExists "gui_${md_id}"; then
                options+=(C "Configuration & Options")
            fi
            options+=(X "Remove")
        fi

        if [[ -d "$__builddir/$md_id" ]]; then
            options+=(Z "Clean source folder")
        fi

        local help="${__mod_desc[$idx]}\n\n${__mod_help[$idx]}"
        if [[ -n "$help" ]]; then
            options+=(H "Package Help")
        fi

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose an option for ${__mod_id[$idx]}\n$status" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        local logfilename

        case "$choice" in
            I)
                clear
                archrgs_logInit
                {
                    archrgs_logStart
                    archrgs_installModule "$idx"
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            S)
                clear
                archrgs_logInit
                {
                    archrgs_logStart
                    archrgs_callModule "$idx" clean
                    archrgs_callModule "$idx"
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            C)
                archrgs_logInit
                {
                    archrgs_logStart
                    archrgs_callModule "$idx" gui
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            X)
                local text="Are you sure you want to remove $md_id?"
                [[ "${__mod_section[$idx]}" == "core" ]] && text+="\n\nWARNING - core packages are needed for Arch-RGS to function!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                archrgs_logInit
                {
                    archrgs_logStart
                    archrgs_callModule "$idx" remove
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            H)
                printMsgs "dialog" "$help"
                ;;
            Z)
                archrgs_callModule "$idx" clean
                printMsgs "dialog" "$__builddir/$md_id has been removed."
                ;;
            *)
                break
                ;;
        esac

    done
}

function section_gui_setup() {
    local section="$1"

    local default=""
    while true; do
        local options=()

        options+=(
            I "Install/Update all ${__sections[$section]} packages" "I This will install all ${__sections[$section]} packages via makepkg."
            X "Remove all ${__sections[$section]} packages" "X This will remove all $section packages."
        )

        local idx
        for idx in $(archrgs_getSectionIds $section); do
            if archrgs_isInstalled "$idx"; then
                installed="(Installed)"
            else
                installed=""
            fi
            options+=("$idx" "${__mod_id[$idx]} $installed" "$idx ${__mod_desc[$idx]}"$'\n\n'"${__mod_help[$idx]}")
        done

        local cmd=(dialog --colors --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            # remove HELP
            choice="${choice[@]:5}"
            # get id of menu item
            default="${choice/%\ */}"
            # remove id
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi

        default="$choice"

        local logfilename
        case "$choice" in
            I)
                dialog --defaultno --yesno "Are you sure you want to install/update all $section packages via makepkg?" 22 76 2>&1 >/dev/tty || continue
                archrgs_logInit
                {
                    archrgs_logStart
                    for idx in $(archrgs_getSectionIds $section); do
                        archrgs_installModule "$idx"
                    done
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            S)
                dialog --defaultno --yesno "Are you sure you want to install/update all $section packages from source?" 22 76 2>&1 >/dev/tty || continue
                archrgs_logInit
                {
                    archrgs_logStart
                    for idx in $(archrgs_getSectionIds $section); do
                        archrgs_callModule "$idx" clean
                        archrgs_callModule "$idx"
                    done
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;

            X)
                local text="Are you sure you want to remove all $section packages?"
                [[ "$section" == "core" ]] && text+="\n\nWARNING - core packages are needed for Arch-RGS to function!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                archrgs_logInit
                {
                    archrgs_logStart
                    for idx in $(archrgs_getSectionIds $section); do
                        archrgs_isInstalled "$idx" && archrgs_callModule "$idx" remove
                    done
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            *)
                package_setup "$choice"
                ;;
        esac

    done
}

function config_gui_setup() {
    local default
    while true; do
        local options=()
        local idx
        for idx in "${__mod_idx[@]}"; do
            # show all configuration modules and any installed packages with a gui function
            if [[ "${__mod_section[idx]}" == "config" ]] || archrgs_isInstalled "$idx" && fnExists "gui_${__mod_id[idx]}"; then
                options+=("$idx" "${__mod_id[$idx]}  - ${__mod_desc[$idx]}" "$idx ${__mod_desc[$idx]}")
            fi
        done

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi

        [[ -z "$choice" ]] && break

        default="$choice"

        local logfilename
        archrgs_logInit
        {
            archrgs_logStart
            if fnExists "gui_${__mod_id[choice]}"; then
                archrgs_callModule "$choice" depends
                archrgs_callModule "$choice" gui
            else
                archrgs_callModule "$idx" clean
                archrgs_callModule "$choice"
            fi
            archrgs_logEnd
        } &> >(_setup_gzip_log "$logfilename")
        archrgs_printInfo "$logfilename"
    done
}

function update_packages_setup() {
    clear
    local idx
    for idx in ${__mod_idx[@]}; do
        if archrgs_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]]; then
            archrgs_installModule "$idx"
        fi
    done
}

function update_packages_gui_setup() {
    local update="$1"
    if [[ "$update" != "update" ]]; then
        dialog --defaultno --yesno "Are you sure you want to update installed packages?" 22 76 2>&1 >/dev/tty || return 1
        updatescript_setup || return 1
        # restart at post_update and then call "update_packages_gui_setup update" afterwards
        joy2keyStop
        exec "$scriptdir/archrgs_packages.sh" setup post_update update_packages_gui_setup update
    fi

    local update_os=0
    dialog --yesno "Would you like to update Arch Linux?" 22 76 2>&1 >/dev/tty && update_os=1

    clear

    local logfilename
    archrgs_logInit
    {
        archrgs_logStart
        [[ "$update_os" -eq 1 ]] && pacmanUpdate
        update_packages_setup
        archrgs_logEnd
    } &> >(_setup_gzip_log "$logfilename")

    archrgs_printInfo "$logfilename"
    printMsgs "dialog" "Installed packages have been updated."
    gui_setup
}

function basic_install_setup() {
    local idx
    for idx in $(archrgs_getSectionIds core); do
        archrgs_installModule "$idx" || return 1
    done
    return 0
}

function packages_gui_setup() {
    local section
    local default
    local options=()

    for section in core emulators libretrocores ports driver exp; do
        options+=($section "Manage ${__sections[$section]} packages" "$section Choose to install/update/configure packages from the ${__sections[$section]}")
    done

    local cmd
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        section_gui_setup "$choice"
        default="$choice"
    done
}

function uninstall_setup() {
    dialog --defaultno --yesno "Are you sure you want to uninstall Arch-RGS?" 22 76 2>&1 >/dev/tty || return 0
    dialog --defaultno --yesno "Are you REALLY sure you want to uninstall Arch-RGS?\n\n$rootdir will be removed - this includes configuration files for all Arch-RGS components." 22 76 2>&1 >/dev/tty || return 0
    clear
    printHeading "Uninstalling Arch-RGS"
    for idx in "${__mod_idx[@]}"; do
        archrgs_isInstalled "$idx" && archrgs_callModule $idx remove
    done
    rm -rfv "$rootdir"
    dialog --defaultno --yesno "Do you want to remove all the files from $datadir - this includes all your installed ROMs, BIOS files and custom splashscreens." 22 76 2>&1 >/dev/tty && rm -rfv "$datadir"
    if dialog --defaultno --yesno "Do you want to remove all the system packages that Arch-RGS depends on? \n\nWARNING: this will remove packages like SDL even if they were installed before you installed Arch-RGS - it will also remove any package configurations - such as those in /etc/samba for Samba.\n\nIf unsure choose No (selected by default)." 22 76 2>&1 >/dev/tty; then
        clear
        # remove all dependencies
        for idx in "${__mod_idx[@]}"; do
            archrgs_isInstalled "$idx" && archrgs_callModule "$idx" depends remove
        done
    fi
    printMsgs "dialog" "Arch-RGS has been uninstalled."
}

function reboot_setup() {
    clear
	reboot
}

# archrgs-setup main menu
function gui_setup() {
depends_setup
    joy2keyStart
    local default
    while true; do
        local commit=$(git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

        cmd=(dialog --backtitle "$__backtitle" --title "Arch-RGS Setup Script" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Version: $__version\nLast Commit: $commit" 22 76 16)
        options=(
            I "Basic Install" "I This will install all packages from Core which gives a basic Arch-RGS install. Further packages can then be installed later from the Emulators, Ports, Libretrocores and Experimental sections. Packages will be built from source and installed via makepkg."

            U "Update" "U Updates Arch-RGS Setup and all currently installed packages. Will also update OS packages. Packages will be built and installed via makepkg."

            P "Manage Packages" "P Install/Remove and Configure the various components of Arch-RGS, including emulators, ports, and controller drivers."

            C "Configuration & Tools" "C Configuration and Tools. Any packages you have installed that have additional configuration options will also appear here."

            S "Update Arch-RGS Setup script" "S Update this Arch-RGS Setup script. This will update this main management script only, but will not update any software packages. To update packages use the 'Update' option from the main menu, which will also update the Arch-RGS Setup script."

            X "Uninstall Arch-RGS" "X Uninstall Arch-RGS completely."

            R "Perform reboot" "R Reboot your machine."
        )

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break

        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        default="$choice"

        case "$choice" in
            I)
                dialog --defaultno --yesno "Are you sure you want to do a basic install?\n\nThis will install all packages from the 'Core' package section." 22 76 2>&1 >/dev/tty || continue
                clear
                local logfilename
                archrgs_logInit
                {
                    archrgs_logStart
                    basic_install_setup
                    archrgs_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            U)
                update_packages_gui_setup
                ;;
            P)
                packages_gui_setup
                ;;
            C)
                config_gui_setup
                ;;
            S)
                dialog --defaultno --yesno "Are you sure you want to update the Arch-RGS Setup script ?" 22 76 2>&1 >/dev/tty || continue
                if updatescript_setup; then
                    joy2keyStop
                    exec "$scriptdir/archrgs_packages.sh" setup post_update gui_setup
                fi
                ;;
            X)
                local logfilename
                archrgs_logInit
                {
                    uninstall_setup
                } &> >(_setup_gzip_log "$logfilename")
                archrgs_printInfo "$logfilename"
                ;;
            R)
                dialog --defaultno --yesno "Are you sure you want to reboot?\n\nNote that if you reboot when Emulation Station is running, you will lose any metadata changes." 22 76 2>&1 >/dev/tty || continue
                reboot_setup
                ;;
        esac
    done
    joy2keyStop
    clear
}
