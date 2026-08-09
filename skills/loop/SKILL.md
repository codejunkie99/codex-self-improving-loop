---
name: loop
description: Run the self-improving DeepSeek/Luna/Sol loop. Use when the user says "/loop", "$loop start", or asks to start a self-improving loop with a task, including a repeating 10-minute cadence.
---

# /loop skill

Run the self-improving loop: DeepSeek runs the task, Luna grades each run, Sol
rewrites the prompt. The user says "$loop start <task>" or "/loop <task>".

## Start

1. If the project has no `prompt.md`, copy the template from
   `loop/prompt.md` into the project root.
2. Replace the task text in `prompt.md` with the user's task. Keep the DONE:
   convention from the template.
3. Run from the project directory:

   ```bash
   bash ./loop.sh
   ```

   Add `--every 600` when the user asks for a 10-minute cadence.

## Utility menu

When the user mentions a utility, map it to a model:

| Utility | Model |
| --- | --- |
| fast / flash | `opencode-go/deepseek-v4-flash` |
| deep / deepseek | `opencode-go/deepseek-v4-pro` |
| luna / grade / watch | `gpt-5.6-luna` |
| sol / review / rewrite | `gpt-5.6-sol` |
| build / implement | `opencode-go/deepseek-v4-pro` |

The same mapping is available as slash commands: `/loop`, `/flash`,
`/deepseek`, `/luna`, `/sol`, and `/utility` for the menu.

## Stop conditions

The driver stops when the runner reports DONE:, when 6 cycles run, or when two
consecutive cycles leave `prompt.md` unchanged. The user can also say stop,
which means interrupt the run and keep the current `prompt.md` and `log.md`.
