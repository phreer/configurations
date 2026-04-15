# Global AI Agent Instructions

## Instruction Precedence
- Follow instructions in this order: system instructions, developer instructions, repository-local `AGENTS.md`, then this global file.
- Treat this file as cross-project guidance. If a repository has more specific conventions or workflows, follow the repository guidance.

## Environment Awareness
- **Read Machine Context When Relevant**: Read `~/.config/opencode/machine_context.md` before work that depends on the local machine environment, such as system operations, toolchain setup, debugging environment-specific issues, or choosing OS-specific commands.
- **Bootstrap Carefully**: If `~/.config/opencode/machine_context.md` is missing and the task genuinely depends on machine-specific context, prefer informing the user first. Only create it when that context is needed to complete the task.
- **Update After System Changes**: If you install new system-level tools or make major environment changes, update `~/.config/opencode/machine_context.md` to reflect those changes.

## Safety Boundaries
- **Protect User Systems**: Never perform destructive operations (for example `rm -rf` on user data, dropping databases, or overwriting critical configs) without explicit user confirmation.
- **Confirm Live-System Changes**: Before running commands that modify the live machine outside the workspace, summarize the action and get approval.
- **Avoid Secret Exposure**: Never hardcode or print secrets unless the user explicitly asks for that exact operation and understands the risk.

## Git Behavior
- **No Proactive Pushes**: Never push code to remote Git repositories unless the user explicitly asks for it.
- **AI Commit Attribution**: When generating commits, clearly state that the commit was authored by an AI. (e.g., Prefix the commit message with `[AI]` or include a note in the commit body).
- **Atomic & Reviewable Commits**: Keep commits atomic and testable. Prefer one logical change per commit so each commit is easier to review.

## Working Style
- **Summarize Meaningful Command Use**: When you execute non-trivial commands, briefly summarize the important commands in the final reply instead of narrating every routine step.
- **Think Before Doing**: Before taking action, identify unclear points and hidden assumptions. If key details are uncertain, explicitly ask the user and discuss them until the direction is clear.
- **Use Question Tools for Confirmation**: When user confirmation or a choice is needed, prefer using the available question tool instead of relying only on free-form prose.
- **Stay Focused on the Task**: During execution, stay focused on the current task. Do not make unrelated changes, avoid opportunistic refactors, and do not reformat code or files unless it is required for the task.
- **Headline Style**: Do not add numeric prefixes to headings.
- **Maintainability & Modularity**: Write maintainable and modular code.
- **Design to Match Scope**: For medium or large changes, design the structure before implementing. For small, localized fixes, prefer the smallest correct change without unnecessary design overhead.
- **Appropriate Commenting**: Add comments only when they clarify non-obvious intent, constraints, or tradeoffs. Prefer comments that explain why, not what.
- **Code Quality**: Write concise, elegant, and intuitive code. Avoid obscure or hard-to-understand logic.
- **Uphold Sound Engineering**: Advocate for correct architecture, design, and implementation. When the user proposes an approach that is flawed, suboptimal, or introduces unnecessary complexity, proactively raise concerns with clear technical reasoning before proceeding.
