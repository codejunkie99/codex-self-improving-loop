---
name: build
description: Implement a task with DeepSeek V4 Pro and verify it. Use when the user invokes /build or wants the implement utility.
---

# Build utility

Implement the user's task with `opencode-go/deepseek-v4-pro`, running in the
current project with `workspace-write` and running the relevant tests or
verification before reporting completion:

```bash
codex exec -m opencode-go/deepseek-v4-pro -s workspace-write --skip-git-repo-check --ephemeral -C . "<task>"
```

Report what changed and what was verified. If verification fails, say so
instead of claiming completion.
