# AGENTS.md

Welcome to the configuration and dotfiles repository! This file provides guidelines for AI coding agents operating in this repository to ensure changes are idiomatic, safe, and consistent.

## 1. Repository Context
This repository contains personal system configurations, dotfiles, and setup scripts for Unix-like environments (macOS and Linux). It does not use a traditional compiler or test runner. Instead, the focus is on system configuration, shell initialization, tool setups (Vim, Tmux, Kitty, Alacritty, etc.), and automation scripts.

## 2. Build, Run, and Test Commands

### "Building" and Deploying
The primary "build" step is applying the configuration to the local system via symlinks.
To apply changes, use the main deployment script:
```bash
# Run the link creation script to deploy dotfiles
bash unix-scripts/create_links.sh
```
*Note: Before running this command for the user, clearly explain which files will be overwritten or symlinked.*

### Linting and "Testing" Shell Scripts
There is no automated test suite. "Testing" involves verifying shell script syntax and safely sourcing configurations.
```bash
# Lint shell scripts using shellcheck (if available on the system)
shellcheck unix-scripts/create_links.sh

# Perform a dry-run syntax check for Bash scripts
bash -n path/to/script.sh

# To test shell startup scripts safely, open a subshell or source them directly
# (Always verify with the user before sourcing complex configurations)
bash -c "source unix-scripts/init.sh"
```

## 3. Code Style and Conventions

### 3.1 Shell Script Standards
- **Indentation:** Use 2 spaces for indentation. Do not use tabs.
- **Error Handling:** Start standalone scripts with strict error handling: `set -eu` or `set -euo pipefail`.
- **Naming Conventions:**
  - Constants and environment variables: `UPPER_CASE` (e.g., `PREFIX_OS`, `SCRIPT_DIR`).
  - Functions: `PascalCase` (e.g., `CopyFileIfNotExist`, `CreateSymbolicLink`) or `snake_case`.
  - Local variables: `snake_case` or `camelCase` and explicitly declare them with `local`.
- **Portability:** Write POSIX-compliant scripts (`#!/bin/sh`) whenever possible, unless Bash-specific (`#!/bin/bash`) or Zsh-specific features are explicitly required.

### 3.2 Init Script Conventions (Crucial Architecture)
Follow the established architecture in `unix-scripts/init-script-convention.md` when modifying shell startup logic:
- **`$PREFIX_OS-init.$SUFFIX_SHELL`**: The platform and shell-specific entry point (e.g., `linux-init.zsh`, `osx-init.sh`).
- **`init.$SUFFIX_SHELL`**: OS-agnostic, shell-specific configuration (e.g., `init.zsh`, `init.sh`).
- **`$PREFIX_OS-init.rc`**: Shell-agnostic, OS-specific configuration (e.g., `linux-init.rc`).
- **`init.rc`**: Truly common settings (OS-agnostic and shell-agnostic).
*Loading order generally cascades: specific OS/Shell config -> loads init.rc -> loads init.$SUFFIX_SHELL -> loads $PREFIX_OS-init.rc.*

### 3.3 Platform Awareness
The environment actively supports both Linux (`linux`) and macOS (`osx` / Darwin).
- When writing scripts or tool configs, always check the OS environment using `uname` or the `$PREFIX_OS` variable where available.
- Ensure package manager commands gracefully degrade or branch correctly (`apt` / `pacman` for Linux, `brew` for macOS).

### 3.4 Configuration Files (Dotfiles)
- **Modifying Tool Configs:** When editing configs (e.g., `.vimrc`, `alacritty.yml`, `tmux.conf`), respect the existing syntax, commenting style, and structure of the file.
- **Adding New Tools:** Place new configuration folders logically (often inside `.config/` following the XDG Base Directory specification) rather than cluttering the home root directory.
- **Idempotency:** Any script or configuration added must be idempotent. Running it twice should not result in duplicated lines, errors, or broken symlinks.

## 4. Security and Safety Rules
- **No Destructive Actions:** Never execute `rm -rf` on the user's home directories or system paths without explicit confirmation.
- **Avoid Secrets:** Never hardcode API keys, passwords, or SSH keys in these dotfiles. If a script requires a secret, prompt the user or load it from a secure, non-version-controlled location (like `~/.netrc` or a keyring).
- **Verify Execution:** Before running commands that modify the live system environment (installing packages, restarting systemd services, modifying `~/.bashrc`), summarize the action to the user and await approval.
