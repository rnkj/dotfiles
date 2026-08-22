#!/usr/bin/env bash
#
# Symlink helper shared by the setup scripts. Source it, then call link_file:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/link.sh"
#   link_file "neovim/config" ".config/nvim"
#
# Requires bash (uses `local`); the caller keeps its own list of links.

# Repository root, resolved from this file so it does not depend on the caller.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# link_file <path in this repo> <path relative to $HOME>
# Both files and directories can be linked.
link_file() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$2"

    if [ ! -e "$src" ]; then
        echo "skip (not found): $1"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    # If the destination exists and is not a symlink, back it up.
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="$dst.bak"
        # Never move into an existing backup directory: pick a free name.
        if [ -e "$backup" ]; then
            backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
            local i=1
            while [ -e "$backup" ]; do
                backup="$dst.bak.$(date +%Y%m%d%H%M%S).$i"
                i=$((i + 1))
            done
        fi
        echo "backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi

    ln -sfn "$src" "$dst"
    echo "linked: $2 -> $1"
}
