# Claude code

A preset of configuration files for Claude Code.
It bundles the settings to drop into a project (`AGENTS.md`, `CLAUDE.md`, `.claude/`, `.agents/`, `.devcontainer/`).

## Structure

```
.
├── AGENTS.md          # Project guide for agents (template)
├── CLAUDE.md          # Entry point that just imports AGENTS.md
├── .claude/
│   ├── settings.json  # Permission settings (deny / ask)
│   └── skills -> ../.agents/skills
├── .agents/
│   ├── rules/         # Always-applied rules (*.mdc)
│   ├── memory/        # MEMORY.md and the individual memory files
│   └── skills/        # Skills directory
├── .devcontainer/
│   └── devcontainer.json  # Sandbox container with Claude Code
└── scripts/
    └── copy_settings.sh   # Copies the settings into a project
```

## Copying the settings

Use `scripts/copy_settings.sh` to copy the settings in this repository into another project.

```bash
bash ./scripts/copy_settings.sh <dest-dir>
# For options, see the help:
# bash ./scripts/copy_settings.sh --help
```

## Using `.devcontainer`

Using `.devcontainer/` requires **Docker** and **DevPod**.

See [scripts/install_docker.sh](../scripts/install_docker.sh) for the installation steps.
The command to install DevPod is printed as a message after running that script.
