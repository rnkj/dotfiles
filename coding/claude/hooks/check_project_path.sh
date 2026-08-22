#!/usr/bin/env bash
#
# PreToolUse hook for Read|Write|Edit.
# Mirrors the `sandbox.filesystem` rules of the adjacent settings.json so that
# the Read/Write/Edit tools get the same scope as sandboxed Bash commands:
#
#   Read       : allowed anywhere, except paths under `denyRead`.
#                A more specific `allowRead` re-opens part of a denied region.
#   Write/Edit : allowed only under the project root, the session temp dir
#                (/tmp/claude-<uid>/...), and `allowWrite` paths.
#                A more specific `denyWrite` blocks part of an allowed region.
#
# Path syntax follows the sandbox rules: `/abs`, `~/rel-to-home`,
# `./rel` or bare `rel` (relative to the project root). Simple globs (`*`, `**`)
# are matched with bash pattern matching.

set -u

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")
fp=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[ -z "$fp" ] && exit 0

root=$(realpath -m "${CLAUDE_PROJECT_DIR:-$PWD}")
settings="$(cd "$(dirname "$(realpath "$0")")/.." && pwd)/settings.json"

# /dev/fd/N, /dev/stdin, /dev/stdout, /dev/stderr are magic symlinks into
# /proc/self/fd/N, which resolve to whatever the fd currently points at
# (often a pipe or socket, e.g. /proc/<pid>/fd/pipe:[...]). Resolving them
# would make the literal path unmatchable against any static allow entry,
# so compare these by their literal (non-symlink-resolved) path instead.
case "$fp" in
  /dev/fd/*|/dev/stdin|/dev/stdout|/dev/stderr)
    rp=$(realpath -m -s "$fp") ;;
  *)
    rp=$(realpath -m "$fp") ;;
esac

deny() {
  jq -cn --arg reason "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
}

# Expand a sandbox-style path to an absolute path.
resolve() {
  local p=$1
  case "$p" in
    "~")   p=$HOME ;;
    "~/"*) p="$HOME/${p#\~/}" ;;
    /*)    ;;
    ./*)   p="$root/${p#./}" ;;
    .)     p=$root ;;
    *)     p="$root/$p" ;;
  esac
  p=${p%/}
  printf '%s\n' "$p"
}

# True if $rp is equal to or below pattern $1.
under() {
  # shellcheck disable=SC2053
  [[ "$rp" == $1 || "$rp" == $1/* ]]
}

# Print the length of the longest matching entry of a list (0 = no match).
# Longer match == more specific rule.
best_match() {
  local best=0 p
  for p in "$@"; do
    [ -z "$p" ] && continue
    p=$(resolve "$p")
    if under "$p" && [ "${#p}" -gt "$best" ]; then best=${#p}; fi
  done
  echo "$best"
}

# Load a string array from settings.json into a bash array.
load() { # $1 = bash array name, $2 = jq path
  local -n _arr=$1
  _arr=()
  if [ -r "$settings" ]; then
    mapfile -t _arr < <(jq -r "$2 // [] | .[]" "$settings" 2>/dev/null)
  fi
}

case "$tool" in
  Read)
    load deny_list  '.sandbox.filesystem.denyRead'
    load allow_list '.sandbox.filesystem.allowRead'
    d=$(best_match "${deny_list[@]}")
    a=$(best_match "${allow_list[@]}")
    if [ "$d" -gt 0 ] && [ "$d" -ge "$a" ]; then
      deny "Read of $rp is blocked by sandbox.filesystem.denyRead."
    fi
    ;;
  *)  # Write | Edit
    load deny_list  '.sandbox.filesystem.denyWrite'
    load allow_list '.sandbox.filesystem.allowWrite'
    # Defaults that the sandbox always grants: project root and session temp dir.
    allow_list+=("$root" "/tmp/claude-$(id -u)")
    [ -n "${TMPDIR:-}" ] && allow_list+=("$TMPDIR")
    d=$(best_match "${deny_list[@]}")
    a=$(best_match "${allow_list[@]}")
    if [ "$a" -eq 0 ]; then
      deny "$tool to $rp is outside the project root, session temp dir, and sandbox.filesystem.allowWrite."
    fi
    if [ "$d" -gt 0 ] && [ "$d" -ge "$a" ]; then
      deny "$tool to $rp is blocked by sandbox.filesystem.denyWrite."
    fi
    ;;
esac

exit 0
