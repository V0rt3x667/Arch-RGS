#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="launching_images"
archrgs_module_desc="Generate runcommand Launching Images Based on Emulationstation Themes"
archrgs_module_help="A runcommand launching image is displayed while loading a game, with this tool you can automatically create some cool images based on a chosen emulationstation theme you have on your system."
archrgs_module_section="exp"
archrgs_module_flags="noinstclean"

function depends_launching_images() {
  local depends=(
    feh
    imagemagick
    librsvg
    xorg-xrandr
  )
  getDepends "${depends[@]}"
}

function install_bin_launching_images() {
  install -Dm755 "$md_data"/{generate-launching-images.sh, material.cfg} -t "$md_inst"
}

function _show_images_launching_images() {
  local image
  local timeout=5
  local is_list=0

  if [[ "$1" = "1" ]]; then
    is_list=1
    shift
  fi

  [[ -f "$1" ]] || return 1
  image="$1"

  feh \
    --on-last-slide quit \
    --hide-pointer \
    --fullscreen \
    --auto-zoom \
    --no-menus \
    --slideshow-delay $timeout \
    --quiet \
    $([[ "$is_list" -eq 1 ]] && echo --filelist) \
    "$image"
}

function _dialog_menu_launching_images() {
  local text="$1"
  shift
  local options=()
  local choice
  local opt
  local i

  [[ "$#" -eq 0 ]] && return 1

    i=1
    for opt in "$@"; do
        options+=( "$i" "$opt" )
        ((i++))
    done
    choice=$(dialog --backtitle "$__backtitle" --menu "$text" 22 86 16 "${options[@]}" 2>&1 >/dev/tty) || return
    echo "${options[choice*2-1]}"
}

function _set_theme_launching_images() {
  _dialog_menu_launching_images "List of available themes" $("$md_inst/generate-launching-images.sh" --list-themes) || echo "$theme"
}

function _set_system_launching_images() {
  local options=()
  local choice
  options=(all)
  options+=($("$md_inst/generate-launching-images.sh" --list-systems))
  choice=$(
    _dialog_menu_launching_images \
      "List of available systems.\n\nSelect the system you want to generate a launching image or \"all\" to generate for all systems." "${options[@]}"
  )
  case "$choice" in
  "all")
    echo ""
    ;;
  "")
    echo "$system"
    ;;
  *)
    echo "--system $choice"
    ;;
  esac
}

function _set_extension_launching_images() {
  _dialog_menu_launching_images "Choose the file extension of the final launching image." png jpg || echo "$extension"
}

function _set_show_timeout_launching_images() {
    _dialog_menu_launching_images \
        "Set how long the image will be displayed before asking if you accept (in seconds)" \
        1 2 3 4 5 6 7 8 9 10 \
    || echo "$show_timeout"
}

function _set_loading_text_launching_images() {
  dialog \
    --backtitle "$__backtitle" \
    --inputbox "Enter the \"NOW LOADING\" text (or leave blank to no text):" \
	0 70 "NOW LOADING" 2>&1 >/dev/tty || echo "$loading_text"
}

function _set_press_button_text_launching_images() {
  dialog \
    --backtitle "$__backtitle" \
    --inputbox "Enter the \"PRESS A BUTTON\" text (or leave blank to no text):" \
	0 70 "PRESS A BUTTON TO CONFIGURE LAUNCH OPTIONS" \
    2>&1 >/dev/tty || echo "$press_button_text"
}

function _select_color_launching_images() {
    _dialog_menu_launching_images \
        "Pick a color for the $1" \
        white black silver gray gray10 gray25 gray50 gray75 gray90 \
        red orange yellow green cyan blue cyan purple pink brown
}

function _set_loading_text_color_launching_images() {
  _select_color_launching_images "\"LOADING\" text" || echo "$loading_text_color"
}

function _set_press_button_text_color_launching_images() {
  _select_color_launching_images "\"PRESS A BUTTON\" text" || echo "$press_button_text_color"
}

function _set_solid_bg_color_launching_images() {
  local choice
  local cmd=(dialog --backtitle "$__backtitle" --menu "Color to use as background" 22 86 16)
  local options=(
    0 "Disable \"solid background color\""
    1 "Use the system color defined by theme"
    2 "Select a color"
  )
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  case "$choice" in
  0)
    echo
    ;;
  1)
    echo "--solid-bg-color"
    ;;
  2)
    echo "--solid-bg-color $(_select_color_launching_images background)"
    ;;
  *)
    echo "$solid_bg_color"
    ;;
  esac
}

function _dialog_yesno_launching_images() {
  dialog --backtitle "$__backtitle" --yesno "$@" 20 60 2>&1 >/dev/tty
}

function _set_no_ask_launching_images() {
  _dialog_yesno_launching_images "If you enable \"no_ask\" all generated images will be automatically accepted.\n\nDo you want to enable it?" \
  && echo "--no-ask"
}

function _set_no_logo_launching_images() {
  _dialog_yesno_launching_images "If you enable \"no_logo\" the images won't have the system logo (useful for tronkyfran theme, for example).\
    \n\nDo you want to enable it?" && echo "--no-logo"
}

function _set_logo_belt_launching_images() {
  _dialog_yesno_launching_images "If you enable \"logo_belt\" the image will have a semi-transparent white belt behind the logo.\
    \n\nDo you want to enable it?" && echo "--logo-belt"
}

function _get_all_launching_images() {
  find "$configdir" -type f -regex ".*launching\.\(png\|jpg\)" | sort
}

function _is_theme_chosen_launching_images() {
  if [[ -z "$1" ]]; then
    printMsgs "dialog" "You didn't choose a theme!\n\nGo to the \"Image generation settings\" and choose one."
    return 1
  fi
}

function _get_config_file_launching_images() {
  local file_list=$(find "$md_inst" -type f -name '*.cfg' ! -name '.current.cfg' | sort | xargs)
  if [[ -z "$file_list" ]]; then
    printMsgs "dialog" "There's no config file saved."
    return 1
  fi
  _dialog_menu_launching_images "Choose the file" $file_list ##XXX: NO QUOTES SURROUNDING $file_list IS MANDATORY!
  return $?
}

function _load_config_launching_images() {
  echo "$(loadModuleConfig \
      'theme=' \
      'extension=png' \
      'show_timeout=5' \
      'loading_text=NOW LOADING' \
      'press_button_text=PRESS A BUTTON TO CONFIGURE LAUNCH OPTIONS' \
      'loading_text_color=white' \
      'press_button_text_color=gray50' \
      'no_ask=' \
      'no_logo=' \
      'solid_bg_color=' \
      'system=' \
      'logo_belt='
  )"
}

function _settings_launching_images() {
  local cmd=(dialog --backtitle "$__backtitle" --title " SETTINGS " --cancel-label "Back" --menu "runcommand launching images generation settings." 22 86 16)
  local options
  local choice
  local config_file

  iniConfig ' = ' '"' "$current_cfg"

    while true; do
        eval $(_load_config_launching_images)

        options=( 
            config_file "$(
               [[ "$config_file" == *"$theme.cfg" ]] && echo "$(basename "$config_file")"
            )"
            theme "$theme"
            system "$(
                if [[ -z "$system" ]]; then
                    echo "all systems in es_systems.cfg"
                else
                    echo "$system" | cut -d' ' -f2
                fi
            )"
            extension ".$extension"
            loading_text "\"$loading_text\""
            press_button_text "\"$press_button_text\""
            loading_text_color "$loading_text_color"
            press_button_text_color "$press_button_text_color"
            show_timeout "$( [[ -n "$no_ask" ]] && echo "don't show (see no_ask)" || echo "$show_timeout seconds")"
            no_ask "$( [[ -n "$no_ask" ]] && echo true || echo false)"
            no_logo "$( [[ -n "$no_logo" ]] && echo true || echo false)"
            logo_belt "$( [[ -n "$logo_belt" ]] && echo true || echo false)"
            solid_bg_color "$(
                if [[ -z "$solid_bg_color" ]]; then
                    echo false
                elif [[ -z "$(echo "$solid_bg_color" | cut -s -d' ' -f2)" ]]; then
                    echo "get from the theme"
                else
                    echo "$solid_bg_color" | cut -s -d' ' -f2
                fi
            )"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        [[ -z "$choice" ]] && break

        if [[ "$choice" = "config_file" ]]; then
            config_file=$(_manage_config_file_launching_images)
            continue
        fi

        iniSet "$choice" "$(_set_${choice}_launching_images)"
    done
}

function _manage_config_file_launching_images() {
  local choice
  local config_file

  eval $(_load_config_launching_images)

  while true; do
    choice=$(
      dialog --backtitle "$__backtitle" --title " CONFIG FILE " --menu "Choose an option" 22 86 16 \
        1 "Load a file" \
        2 "Save current configs for \"$theme\"" \
        3 "Delete a config file" \
        2>&1 >/dev/tty
    )

    case "$choice" in
    1) ##LOAD CONFIG
      config_file=$(_get_config_file_launching_images) || continue
      cat "$config_file" >"$current_cfg"
      echo "$config_file"
      break
      ;;

    2) ##SAVE CONFIG
      _is_theme_chosen_launching_images "$theme" || break
      config_file="$md_inst/$theme.cfg"
      if [[ -f "$config_file" ]]; then
        _dialog_yesno_launching_images "\"$(basename "$config_file")\" exists.\nDo you want to overwrite it?" || continue
      fi
      cat "$current_cfg" >"$config_file"
      printMsgs "dialog" "\"$(basename "$config_file")\" saved!"
      echo "$config_file"
      break
      ;;

    3) ##DELETE CONFIG
      config_file=$(_get_config_file_launching_images) || continue
      _dialog_yesno_launching_images "Are you sure you want to delete \"$config_file\"?" || continue
      local err_msg=$(rm -v "$config_file")
      printMsgs "dialog" "$err_msg"
      ;;

    *)
      break
      ;;
    esac
  done
}

function _generate_launching_images() {
  eval $(_load_config_launching_images)

  _is_theme_chosen_launching_images "$theme" || return
  "$md_inst/generate-launching-images.sh" \
    --theme "$theme" \
    --extension "$extension" \
    --show-timeout "$show_timeout" \
    --loading-text "$loading_text" \
    --press-button-text "$press_button_text" \
    --loading-text-color "$loading_text_color" \
    --press-button-text-color "$press_button_text_color" \
    $system \
    $solid_bg_color \
    $no_ask \
    $no_logo \
    $logo_belt \
    2>&1 >/dev/tty

  if [[ "$?" -ne 0 ]]; then
    printMsgs "dialog" "Unable to generate launching images. Please check the \"Image generation settings\"."
    return
  fi

  for file in $(_get_all_launching_images); do
    chown "$user:$user" "$file"
  done
}

function gui_launching_images() {
  local cmd=()
  local options=()
  local choice
  local current_cfg="$md_inst/.current.cfg"

  rm -f "$current_cfg"
  while true; do
    cmd=(dialog --backtitle "$__backtitle" --title " runcommand launching images generation " --menu "Choose an option." 22 86 16)
    options=(
      1 "Image generation settings"
      2 "Generate launching images"
      3 "View slideshow of all current launching images"
      4 "View a specific system's launching image"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
      case "$choice" in
      1) ##IMAGE GENERATION SETTINGS
        _settings_launching_images
        ;;

      2) ##GENERATE LAUNCHING IMAGES
        _generate_launching_images
        ;;

      3) ##VIEW SLIDESHOW OF ALL CURRENT LAUNCHING IMAGES
        local file=$(mktemp)
        _get_all_launching_images >"$file"
        if [[ -s "$file" ]]; then
          _show_images_launching_images 1 "$file"
        else
          printMsgs "dialog" "No launching image found."
        fi
        rm -f "$file"
        ;;

      4) ##VIEW THE LAUNCHING IMAGE OF A SPECIFIC SYSTEM
        while true; do
          local img_list=($(_get_all_launching_images))
          if [[ "${#img_list[@]}" -eq 0 ]]; then
            printMsgs "dialog" "No launching image found."
            break
          fi
          choice=$(_dialog_menu_launching_images "Choose the system" "${img_list[@]}")
          [[ -z "$choice" ]] && break
          _show_images_launching_images "$choice"
        done
        ;;
 
      esac
    else
      break
    fi
  done
  rm -f "$current_cfg"
}

