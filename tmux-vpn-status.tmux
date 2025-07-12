#!/usr/bin/env bash

# vpn status line for tmux
# Displays active vpn connections, with nmcli by default

_get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

# Plugin options, can be set with `set-option -g @<option-name> '<value>'` in tmux.conf file
readonly cmd="$(_get_tmux_option "@vpn-status-cmd" "_tmux_vpn_status_cmd")"
readonly symbol_enable="$(_get_tmux_option "@vpn-status-symbol-enable" "true")"
readonly symbol_color="$(_get_tmux_option "@vpn-status-symbol-color" "yellow")"
readonly text_color="$(_get_tmux_option "@vpn-status-text-color" "yellow")"

# Default function for nmcli
# Can be customized by creating a new function in your shell config and adding `set-option -g @vpn-status-cmd 'your_function_name'`
# Must return the active connections on one line
function _tmux_vpn_status_cmd() {
  nmcli -t -f NAME,TYPE con show --active | awk -F: '($2=="vpn"||$2=="wireguard"){print $1}' | tr "\n" , | rev | cut -d, -f2- | rev
}

_tmux_vpn_status_symbol() {
  if ((BASH_VERSINFO[0] >= 4)) && [[ $'\u2301 ' != "\\u2301 " ]]; then
    TMUX_VPN_STATUS_SYMBOL=$'\u2301 '
  else
    TMUX_VPN_STATUS_SYMBOL=$'\xE2\x8C\x81 '
  fi
  echo "${TMUX_VPN_STATUS_SYMBOL}"
}

do_interpolation() {
  local string="$1"
  local interpolated="${string/$vpn_status_interpolation_string/$vpn_status}"
  echo "$interpolated"
}

set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "$option" "$value"
}

update_tmux_option() {
  local option="$1"
  local option_value="$(get_tmux_option "$option")"
  local new_option_value="$(do_interpolation "$option_value")"
  set_tmux_option "$option" "$new_option_value"
}

main() {
  local TMUX_VPN_STATUS

  # Symbol
  if [[ "${symbol_enable}" == true ]]; then
    TMUX_VPN_STATUS+="#[fg=${symbol_color}]$(_tmux_vpn_status_symbol)#[fg=colour${1}]"
  fi

  # VPN active connectons
  CMD_OUTPUT="$($cmd 2>/dev/null)"
  if [ -z "${CMD_OUTPUT}"]; then
    TMUX_VPN_STATUS=""
  else
    TMUX_VPN_STATUS+="#[fg=colour250]#[fg=${3}]#[fg=${text_color}]${CMD_OUTPUT}"
  fi

  echo "${TMUX_VPN_STATUS}"
}

main "$@"
