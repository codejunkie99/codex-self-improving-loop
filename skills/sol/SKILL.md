---
name: sol
description: Use Sol to review work or rewrite prompts. Use when the user invokes /sol or wants the Sol utility.
---

# Sol utility

Run the review or rewrite task on `gpt-5.6-sol` with the Codex CLI:

```bash
codex exec -m gpt-5.6-sol -s read-only --skip-git-repo-check --ephemeral -C . "<task>"
```

For rewriting a loop prompt, feed the current `prompt.md` plus `log.md` to Sol
with the rewriter instructions from the self-improving loop, and give
`workspace-write` so it can rewrite `prompt.md` in place. Rewrites stay at most
20% larger than the original.
