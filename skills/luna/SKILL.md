---
name: luna
description: Use Luna to watch, grade, or run bounded worker tasks. Use when the user invokes /luna or wants the Luna utility.
---

# Luna utility

Run the task on `gpt-5.6-luna` with the Codex CLI:

```bash
codex exec -m gpt-5.6-luna -s read-only --skip-git-repo-check --ephemeral -C . "<task>"
```

For grading a loop run, feed the current `prompt.md` plus `log.md` to Luna with
the watcher instructions from the self-improving loop. Luna never rewrites
prompts; it grades and emits GOAL, KEPT, WASTED, FAILED, NEXT.
