#!/usr/bin/env bash
# tmux 3.7 can restore a layout smaller than its enclosing window. This leaves
# dotted unused space even with one attached client. Preserve the split layout,
# pane processes, and sizing policy while forcing tmux to recalculate its bounds.
set -euo pipefail
tmux list-windows -a -F '#{window_id} #{window_width} #{window_height} #{window_layout} #{window_zoomed_flag}' |
  sort -u |
  while read -r window width height layout zoomed; do
    [[ "$zoomed" == 1 ]] && continue
    bounds="${layout#*,}"
    bounds="${bounds%%,*}"
    [[ "$bounds" == "${width}x${height}" ]] && continue
    # Save only a local override; unset afterwards when the policy was inherited.
    policy=$(tmux show-options -wqv -t "$window" window-size)
    tmux resize-window -t "$window" -x "$((width + 1))" -y "$height" \; \
      resize-window -t "$window" -x "$width" -y "$height"
    if [[ -n "$policy" ]]; then
      tmux set-option -w -t "$window" window-size "$policy"
    else
      tmux set-option -wu -t "$window" window-size
    fi
  done
