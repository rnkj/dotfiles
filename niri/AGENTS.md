# Niri dotfile -- Agent Guide

Research how to use Niri, and support configuration and customization.

---

## Scope of Work

1. Usage research: investigate how to use Niri and how to solve problems, in response to the user's questions.

2. Customization support: identify a customization approach that satisfies the user's request, and actually apply it.

---

## Customization Workflow

1. Before starting work, confirm that no uncommitted changes remain under `niri/`
  ```
  git status "$(git rev-parse --show-toplevel)/niri"
  ```

2. Create a candidate file and validate it with `niri validate -c <candidate>` (exit 0 is required)

3. Start a nested session with `niri -c <candidate>` and check the behavior inside that window (do not pass `--session`)

4. Apply it to the live config. Niri reloads automatically when the file is saved

5. If it is rejected, revert with `git checkout -- niri/config.kdl`

---

## Choosing the Verification Environment

- Changes to config.kdl → do not use Docker. The validate → nested start → live apply → git checkout sequence above is sufficient.
- Use Docker for reproducibility checks of install.sh and for investigating the impact of adding a PPA. Run it against a clean state with `docker run --rm -it ubuntu:26.04`, and confirm connectivity and idempotency. Do not try these on the host.
- Docker cannot verify Niri's startup or appearance. Wayland/DRM cannot be isolated there, so use a nested start on the host instead.
- The host has several PPAs, so a container's package state differs from the host's. Do not treat container results as a prediction of host behavior.

---

## Things to Watch For

- Customizations ultimately require the user to confirm the appearance and behavior. That final check can end in rejection, so edit in a way that keeps the original configuration restorable.
- The configuration itself lives at `niri/config.kdl` in this repository, and `~/.config/niri/config.kdl` is a symlink to it.
- Some things cannot be verified with a nested start: monitor configuration (`output`), DRM-dependent rendering, systemd/D-Bus integration, and integration with waybar/dms. These can only be confirmed by applying to the live config.
- Use `niri msg output` to try out `output` settings. Such changes are temporary and revert on restart.
- Config file validation (`niri validate`) only checks syntax and schema. It does not guarantee that referenced targets exist or how things behave at runtime.

---

## Limits and Prohibitions

- Do not start making changes while uncommitted changes remain. The restore point would be lost.
- When applying a change that cannot be verified with a nested start to the live config, always commit before applying.
- Do not write a command in `spawn` / `spawn-at-startup` without confirming it exists via `command -v`. A configuration referencing an uninstalled binary passes Niri's validation, so the failure only surfaces at runtime.
- Do not start Niri with `--session` in the live session. Nested starts for verification must only use `niri -c <candidate>`.
