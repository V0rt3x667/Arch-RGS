#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

declare -A __mod_id_to_idx
declare -A __sections
__sections[core]="core"
__sections[emulators]="emulator"
__sections[libretrocores]="libretro"
__sections[ports]="port"
__sections[exp]="experimental"
__sections[driver]="driver"
__sections[config]="configuration"

function archrgs_listFunctions() {
    local idx
    local mod_id
    local desc
    local mode
    local func

    echo -e "Index/ID:                 Description:                                 List of available actions"
    echo "-----------------------------------------------------------------------------------------------------------------------------------"
    for idx in ${__mod_idx[@]}; do
        mod_id=${__mod_id[$idx]};
        printf "%d/%-20s: %-42s :" "$idx" "$mod_id" "${__mod_desc[$idx]}"
        while read mode; do
            # skip private module functions (start with an underscore)
            [[ "$mode" = _* ]] && continue
            mode=${mode//_$mod_id/}
            echo -n " $mode"
        done < <(compgen -A function -X \!*_$mod_id)
        fnExists "install_${mod_id}" || fnExists "install_bin_${mod_id}" && ! fnExists "remove_${mod_id}" && echo -n " remove"
        echo -n " help"
        echo ""
    done
    echo "==================================================================================================================================="
}

function archrgs_printUsageinfo() {
    echo -e "Usage:\n$0 <Index # or ID>\nThis will run the actions depends, sources, build, install, configure and clean automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <Index # or ID [depends|sources|build|install|configure|clean|remove]\n"
    echo    "Definitions:"
    echo    "depends:    install the dependencies for the module"
    echo    "sources:    install the sources for the module"
    echo    "build:      build/compile the module"
    echo    "install:    install the compiled module"
    echo    "configure:  configure the installed module (es_systems.cfg / launch parameters etc)"
    echo    "clean:      remove the sources/build folder for the module"
    echo    "help:       get additional help on the module"
    echo -e "\nThis is a list of valid modules/packages and supported commands:\n"
    archrgs_listFunctions
}

function archrgs_callModule() {
    local req_id="$1"
    local mode="$2"
    # shift the function parameters left so $@ will contain any additional parameters which we can use in modules
    shift 2

    # if index get mod_id from array else we look it up
    local md_id
    local md_idx
    if [[ "$req_id" =~ ^[0-9]+$ ]]; then
        md_id="$(archrgs_getIdFromIdx $req_id)"
        md_idx="$req_id"
    else
        md_idx="$(archrgs_getIdxFromId $req_id)"
        md_id="$req_id"
    fi

    if [[ -z "$md_id" || -z "$md_idx" ]]; then
        printMsgs "console" "No module '$req_id' found for platform $__platform"
        return 2
    fi

    # automatically build/install module if no parameters are given
    if [[ -z "$mode" ]]; then
        for mode in depends sources build install configure clean; do
            archrgs_callModule "$md_idx" "$mode" || return 1
        done
        return 0
    fi

    # create variables that can be used in modules
    local md_desc="${__mod_desc[$md_idx]}"
    local md_help="${__mod_help[$md_idx]}"
    local md_type="${__mod_type[$md_idx]}"
    local md_flags="${__mod_flags[$md_idx]}"
    local md_build="$__builddir"
    local md_inst="$(archrgs_getInstallPath $md_idx)"
    local md_data="$scriptdir/scriptmodules/$md_type/$md_id"
    local md_mode="install"

    # set md_conf_root to $configdir and to $configdir/ports for ports
    # ports in libretrocores or systems (as ES sees them) in ports will need to change it manually with setConfigRoot
    local md_conf_root
    if [[ "$md_type" == "ports" ]]; then
        setConfigRoot "ports"
    else
        setConfigRoot ""
    fi

    case "$mode" in
        # remove sources
        clean)
            if [[ "$__persistent_repos" -eq 1 ]] && [[ -d "$md_build/$md_id/.git" ]]; then
                git -C "$md_build/$md_id" reset --hard
                git -C "$md_build/$md_id" clean -f -d
            else
                rmDirExists "$md_build/$md_id"
            fi
            return 0
            ;;
        # echo module help to console
        help)
            printMsgs "console" "$md_desc\n\n$md_help"
            return 0;
            ;;
    esac

    # create function name
    function="${mode}_${md_id}"

    # handle cases where we have automatic module functions like remove
    if ! fnExists "$function"; then
        if [[ "$mode" == "install" ]] && fnExists "install_bin_${md_id}"; then
            function="install_bin_${md_id}"
        elif [[ "$mode" != "install_bin" && "$mode" != "remove" ]]; then
            return 0
        fi
    fi

    # these can be returned by a module
    local md_ret_require=()
    local md_ret_files=()
    local md_ret_errors=()
    local md_ret_info=()

    local action
    local pushed=1
    case "$mode" in
        depends)
            if [[ "$1" == "remove" ]]; then
                md_mode="remove"
                action="Removing"
            else
                action="Installing"
            fi
            action+=" dependencies for"
            ;;
        sources)
            action="Getting sources for"
            mkdir -p "$md_build/$md_id"
            pushd "$md_build/$md_id"
            pushed=$?
            ;;
        build)
            action="Building"
            pushd "$md_build/$md_id" 2>/dev/null
            pushed=$?
            ;;
        install|install_bin)
            action="Installing"
            # remove any previous install folder before installing
            if ! hasFlag "${__mod_flags[$md_idx]}" "noinstclean"; then
                rmDirExists "$md_inst"
            fi
            mkdir -p "$md_inst"
            pushd "$md_build" 2>/dev/null
            pushed=$?
            ;;
        configure)
            action="Configuring"
            pushd "$md_inst" 2>/dev/null
            pushed=$?
            ;;
        remove)
            action="Removing"
            ;;
        _update_hook)
            ;;
        *)
            action="Running action '$mode' for"
            ;;
    esac

    # print an action and a description
    if [[ -n "$action" ]]; then
        printHeading "$action '$md_id' : $md_desc"
    fi

    case "$mode" in
        remove)
            fnExists "$function" && "$function" "$@"
            md_mode="remove"
            if fnExists "configure_${md_id}"; then
                pushd "$md_inst" 2>/dev/null
                pushed=$?
                "configure_${md_id}"
            fi
            rm -rf "$md_inst"
            printMsgs "console" "Removed directory $md_inst"
            ;;
        install)
            if fnExists "$function"; then
                "$function" "$@"
            elif fnExists "install_bin_${md_id}"; then
                "install_bin_${md_id}" "$@"
            fi
            ;;
        install_bin)
            if fnExists "install_bin_${md_id}"; then
                if ! "$function" "$@"; then
                    md_ret_errors+=("Unable to install package for $md_id")
                fi
            fi
            ;;
        *)
            # call the function with parameters
            fnExists "$function" && "$function" "$@"
            ;;
    esac

    # check if any required files are found
    if [[ -n "$md_ret_require" ]]; then
        for file in "${md_ret_require[@]}"; do
            if [[ ! -e "$file" ]]; then
                md_ret_errors+=("Could not successfully $mode $md_id - $md_desc ($file not found).")
                break
            fi
        done
    fi

    if [[ "${#md_ret_errors}" -eq 0 && -n "$md_ret_files" ]]; then
        # check for existence and copy any files/directories returned
        local file
        for file in "${md_ret_files[@]}"; do
            if [[ ! -e "$md_build/$file" ]]; then
                md_ret_errors+=("Could not successfully install $md_desc ($md_build/$file not found).")
                break
            fi
            cp -Rvf "$md_build/$file" "$md_inst"
        done
    fi

    # remove build folder if empty
    [[ -d "$md_build" ]] && find "$md_build" -maxdepth 0 -empty -exec rmdir {} \;

    [[ "$pushed" -eq 0 ]] && popd

    # some errors were returned.
    if [[ "${#md_ret_errors[@]}" -gt 0 ]]; then
        __ERRMSGS+=("${md_ret_errors[@]}")
        printMsgs "console" "${md_ret_errors[@]}" >&2
        # if sources fails make sure we clean up
        if [[ "$mode" == "sources" ]]; then
            archrgs_callModule "$md_idx" clean
        fi
        # remove install folder if there is an error (and it is empty)
        [[ -d "$md_inst" ]] && find "$md_inst" -maxdepth 0 -empty -exec rmdir {} \;
        return 1
    fi

    # some information messages were returned
    if [[ "${#md_ret_info[@]}" -gt 0 ]]; then
        __INFMSGS+=("${md_ret_info[@]}")
    fi

    return 0
}

function archrgs_hasPackage() {
    local idx="$1"
    fnExists "install_bin_${__mod_id[$idx]}" && return 0
}

function archrgs_installModule() {
    local idx="$1"
    local mode
    if archrgs_hasPackage "$idx"; then
        for mode in depends install_bin configure; do
            archrgs_callModule "$idx" "$mode" || return 1
        done
    else
        archrgs_callModule "$idx" clean
        archrgs_callModule "$idx" || return 1
    fi
    return 0
}

function archrgs_registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local module_type="$3"
    local archrgs_module_id=""
    local archrgs_module_desc=""
    local archrgs_module_help=""
    local archrgs_module_licence=""
    local archrgs_module_section=""
    local archrgs_module_flags=""
    local var
    local error=0

    source "$module_path"

    for var in archrgs_module_id archrgs_module_desc; do
        if [[ -z "${!var}" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1

    local flags=($archrgs_module_flags)
    local flag
    local valid=1

    for flag in "${flags[@]}"; do
        if [[ "$flag" =~ ^\!(.+) ]] && isPlatform "${BASH_REMATCH[1]}"; then
            valid=0
            break
        fi
    done

    if [[ "$valid" -eq 1 ]]; then
        __mod_idx+=("$module_idx")
        __mod_id["$module_idx"]="$archrgs_module_id"
        __mod_type["$module_idx"]="$module_type"
        __mod_desc["$module_idx"]="$archrgs_module_desc"
        __mod_help["$module_idx"]="$archrgs_module_help"
        __mod_licence["$module_idx"]="$archrgs_module_licence"
        __mod_section["$module_idx"]="$archrgs_module_section"
        __mod_flags["$module_idx"]="$archrgs_module_flags"

        # id to idx mapping via associative array
        __mod_id_to_idx["$archrgs_module_id"]="$module_idx"
    fi
}

function archrgs_registerModuleDir() {
    local module_idx="$1"
    local module_dir="$2"
    for module in $(find "$scriptdir/scriptmodules/$2" -maxdepth 1 -name "*.sh" | sort); do
        archrgs_registerModule $module_idx "$module" "$module_dir"
        ((module_idx++))
    done
}

function archrgs_registerAllModules() {
    __mod_idx=()
    __mod_id=()
    __mod_type=()
    __mod_desc=()
    __mod_help=()
    __mod_licence=()
    __mod_section=()
    __mod_flags=()
    archrgs_registerModuleDir 100 "emulators"
    archrgs_registerModuleDir 200 "libretrocores"
    archrgs_registerModuleDir 300 "ports"
    archrgs_registerModuleDir 800 "supplementary"
    archrgs_registerModuleDir 900 "admin"
}

function archrgs_getIdxFromId() {
    echo "${__mod_id_to_idx[$1]}"
}

function archrgs_getIdFromIdx() {
    echo "${__mod_id[$1]}"
}

function archrgs_getSectionIds() {
    local section
    local id
    local ids=()
    for id in "${__mod_idx[@]}"; do
        for section in "$@"; do
            [[ "${__mod_section[$id]}" == "$section" ]] && ids+=("$id")
        done
    done
    echo "${ids[@]}"
}

function archrgs_isInstalled() {
    local md_idx="$1"
    local md_inst="$rootdir/${__mod_type[$md_idx]}/${__mod_id[$md_idx]}"
    [[ -d "$md_inst" ]] && return 0
    return 1
}

function archrgs_updateHooks() {
    local function
    local mod_idx
    for function in $(compgen -A function _update_hook_); do
        mod_idx="$(archrgs_getIdxFromId "${function/_update_hook_/}")"
        [[ -n "$mod_idx" ]] && archrgs_callModule "$mod_idx" _update_hook
    done
}

function archrgs_getInstallPath() {
    local idx="$1"
    local id=$(archrgs_getIdFromIdx "$idx")
    echo "$rootdir/${__mod_type[$idx]}/$id"
}
