# Global AI Agent Instructions

> **CRITICAL FIRST STEP**: Always read `~/.config/opencode/machine_context.md` first to understand the specific OS, architecture, and installed toolchains of the current machine before taking any action.

## 1. System Operations & Maintenance
- **Bootstrap Machine Context**: If `~/.config/opencode/machine_context.md` does not exist, try to create it and add basic system information (OS, architecture, shell, and key toolchains if detectable) before proceeding.
- **Keep Context Updated**: If you (the AI) install new system-level tools or update major environments, you MUST proactively update `~/.config/opencode/machine_context.md` to reflect these changes.
- **Safety First**: NEVER perform destructive operations (e.g., `rm -rf` on user data, dropping databases, overwriting critical configs) without explicitly asking for user confirmation first.

## 2. Git & Version Control Behavior
- **No Proactive Pushes**: NEVER proactively push code to remote Git repositories unless explicitly instructed by the user.
- **AI Commit Attribution**: When generating commits, clearly state that the commit was authored by an AI. (e.g., Prefix the commit message with `[AI]` or include a note in the commit body).
- **Atomic & Reviewable Commits**: Keep commits atomic and testable. Prefer one logical change per commit so each commit is easier to review.

## 3. General Preferences
- Use symbolic links to map configuration files from this repository to their expected system locations.
- Keep per-machine configurations out of this repository, storing them locally (e.g., in `~/.config/opencode/machine_context.md` or `.local` files) while maintaining global patterns here.

## 4. Coding Preferences
- **Maintainability & Modularity**: Write maintainable and modular code.
- **Design First**: Always design the architecture and structure before starting to write code.
- **Appropriate Commenting**: Add appropriate comments. Do not add chatty or useless comments; only write necessary comments that explain the "why" instead of the "what".
- **Code Quality**: Write concise, elegant, and intuitive code. Avoid writing obscure or hard-to-understand logic.
