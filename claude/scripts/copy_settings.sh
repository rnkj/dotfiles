#!/bin/bash
#
# Copy the agent setting files in this repository to another directory.
#
#   copy_settings.sh [--overwrite] [--dry-run] <dest-dir>
#
# Targets: AGENTS.md CLAUDE.md .claude/ .agents/ .devcontainer/
# Targets missing in the source are skipped with a warning.
# By default nothing is copied if any target already exists in <dest-dir>.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=(AGENTS.md CLAUDE.md .claude .agents .devcontainer)

OVERWRITE=false
DRY_RUN=false
DEST=""

warn() { echo -e "\033[1;33m$*\033[0m" >&2; }
die() { echo -e "\033[1;31m$*\033[0m" >&2; exit 1; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [--overwrite] [--dry-run] <dest-dir>

Copy ${TARGETS[*]} from ${SRC_DIR} into <dest-dir>.

Options:
  --overwrite  Copy even if the target already exists in <dest-dir>
  --dry-run    Show what would be copied without copying
  -h, --help   Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --overwrite) OVERWRITE=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help) usage; exit 0 ;;
        -*) usage >&2; die "Unknown option: $1" ;;
        *)
            [ -n "$DEST" ] && { usage >&2; die "Too many arguments: $1"; }
            DEST="$1"
            ;;
    esac
    shift
done

[ -n "$DEST" ] || { usage >&2; die "No destination directory given"; }

# Collect the targets that actually exist in the source
items=()
for name in "${TARGETS[@]}"; do
    if [ -e "$SRC_DIR/$name" ]; then
        items+=("$name")
    else
        warn "Skip (not found in source): $name"
    fi
done
[ ${#items[@]} -gt 0 ] || die "Nothing to copy from $SRC_DIR"

DEST="${DEST%/}"
if [ -e "$DEST" ] && [ ! -d "$DEST" ]; then
    die "Destination is not a directory: $DEST"
fi

# Unless --overwrite, do not copy anything when any target is already there
if ! $OVERWRITE; then
    existing=()
    for name in "${items[@]}"; do
        [ -e "$DEST/$name" ] && existing+=("$name")
    done
    if [ ${#existing[@]} -gt 0 ]; then
        warn "Already exists in $DEST: ${existing[*]}"
        warn "Nothing was copied. Use --overwrite to copy anyway."
        exit 0
    fi
fi

if $DRY_RUN; then
    echo "[dry-run] mkdir -p $DEST"
    for name in "${items[@]}"; do
        if [ -d "$SRC_DIR/$name" ]; then
            echo "[dry-run] cp -a $SRC_DIR/$name/. $DEST/$name/"
        else
            echo "[dry-run] cp -a $SRC_DIR/$name $DEST/$name"
        fi
    done
    exit 0
fi

mkdir -p "$DEST"
for name in "${items[@]}"; do
    if [ -d "$SRC_DIR/$name" ]; then
        mkdir -p "$DEST/$name"
        cp -a "$SRC_DIR/$name/." "$DEST/$name/"
    else
        cp -a "$SRC_DIR/$name" "$DEST/$name"
    fi
    echo "Copied: $name -> $DEST/$name"
done
