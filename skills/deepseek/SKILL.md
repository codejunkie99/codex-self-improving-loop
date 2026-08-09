---
name: deepseek
description: Run the task on DeepSeek V4 Pro. Use when the user invokes /deepseek or wants deeper DeepSeek reasoning.
---

# DeepSeek V4 Pro utility

Run the user's task on `opencode-go/deepseek-v4-pro` with the Codex CLI:

```bash
codex exec -m opencode-go/deepseek-v4-pro -s workspace-write --skip-git-repo-check --ephemeral -C . "<task>"
```

Choose the sandbox based on the task: `read-only` for inspection, `workspace-write` for edits.
When the task is part of the self-improving loop, run the loop driver with
`--runner-model opencode-go/deepseek-v4-pro` instead.
