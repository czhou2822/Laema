#!/usr/bin/env bash
set -euo pipefail
task_preview_dir="/workspace/homm3-research/gameplay-preview"
DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 \
XDG_DATA_HOME="$task_preview_dir/xdg-data" \
XDG_CONFIG_HOME="$task_preview_dir/xdg-config" \
XDG_CACHE_HOME="$task_preview_dir/xdg-cache" \
godot4 --path "$task_preview_dir/project" --rendering-method gl_compatibility \
  --audio-driver Dummy --script res://research_capture.gd \
  > "$task_preview_dir/normalized-capture.log" 2>&1
