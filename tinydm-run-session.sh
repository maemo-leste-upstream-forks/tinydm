#!/bin/sh
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

setup_log() {
	logfile=${XDG_CACHE_DIR:-~/.cache}/tinydm.log
	mkdir -p "$(dirname "$logfile")"
        if [ -f "$logfile" ]; then
		# keep previous log file around
		mv "$logfile" "$logfile".old
        fi

	exec >"$logfile" 2>&1
}

source_profile() {
	for profile in /etc/profile "$HOME"/.profile; do
		if [ -f "$profile" ]; then
			# shellcheck disable=SC1090
			. "$profile"
		fi
	done
}

# $1: file
# $2: key
parse_xdg_desktop() {
	grep "^$2=" "$1" | cut -d "=" -f 2-
}

# $1: Exec line from .desktop file
run_session_wayland() {
	export XDG_SESSION_TYPE=wayland
	exec "$@"
}

# $1: Exec line from .desktop file
run_session_x() {
	export XDG_SESSION_TYPE=X11

	# startx needs the absolute executable path, otherwise it will not
	# recognize the executable as command to be executed
	cmd_startx="startx $(command -v "$1")"

	# 'Exec' in desktop entries may contain arguments for the executable:
	# https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#exec-variables
	shift
	for arg in "$@"; do
		cmd_startx="$cmd_startx $arg"
	done

	# shellcheck disable=SC2086
	exec $cmd_startx
}

run_session() {
	target="/var/lib/tinydm/default-session.desktop"

	if ! [ -e "$target" ]; then
		echo "ERROR: no session configured!"
		exit 1
	fi

	resolved="$(realpath "$target")"
	cmd="$(parse_xdg_desktop "$resolved" "Exec")"

	echo "--- tinydm ---"
	echo "Date:    $(date)"
	echo "Session: $resolved"
	echo "Exec:    $cmd"
	echo "---"

	case "$resolved" in
		/usr/share/wayland-sessions*)
			# shellcheck disable=SC2086
			run_session_wayland $cmd
			;;
		/usr/share/xsessions*)
			# shellcheck disable=SC2086
			run_session_x $cmd
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

setup_log
source_profile
run_session
