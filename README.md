# tmux-vpn-status

Tmux plugin that displays current active VPN connections in the tmux status line.

Tested and working on Linux with nmcli (NetworkManager), but it can be adapted to other programs or OS.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'alexandregv/tmux-vpn-status'

Hit `prefix + I` to fetch the plugin and source it.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/alexandregv/tmux-vpn-status $HOME/.tmux/plugins/tmux-vpn-status/

Add this line to the bottom of `.tmux.conf`:

    run-shell $HOME/.tmux/plugins/tmux-vpn-status/tmux_vpn_status.tmux

Reload TMUX environment:

    $ tmux source-file ~/.tmux.conf

### Configuration

Add `#(/bin/bash $HOME/.tmux/plugins/tmux-vpn-status/tmux-vpn-status.tmux)` string to your existing status-right or status-left tmux option.

    set-option -g status-right "... #(/bin/bash $HOME/.tmux/plugins/tmux-vpn-status/tmux-vpn-status.tmux) ..."

Optionally configure the plugin with:

    set -g @vpn_status_cmd 'your_custom_bash_function'
    set -g @vpn_status_symbol_enable 'true'
    set -g @vpn_status_symbole_color 'yellow'
    set -g @vpn_status_text_color 'yellow'

### Changing the vpn status function

If you need to change the VPN status retrieving function, for example to make it work with another network program, export a shell function like so:

```bash
function _tmux_vpn_status_cmd_override() {
  # change the content here, function must print the list on one line
  nmcli -t -f NAME,TYPE con show --active | awk -F: '($2=="vpn"||$2=="wireguard"){print $1}' | tr "\n" , | rev | cut -d, -f2- | rev
}
```

Then add `set -g @vpn_status_cmd '_tmux_vpn_status_cmd_override'` in your `tmux.conf` file.
