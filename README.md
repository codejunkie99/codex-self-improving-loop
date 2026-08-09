# Self-improving Codex loop

Three models, two role files, one driver. DeepSeek runs the task from
`prompt.md`, Luna grades each run, Sol rewrites `prompt.md`, and the cycle
repeats until the task is done. The prompt file is the product, everything else
is plumbing.

## Layout

| Path | What it is |
| --- | --- |
| `loop/` | The driver (`loop.sh`) plus `watcher.md`, `rewriter.md`, `prompt.md` |
| `skills/` | Slash-command skills: `/loop`, `/flash`, `/deepseek`, `/luna`, `/sol`, `/build`, `/utility` |
| `demo/` | Runnable demo: a threaded counter bug fixed by the loop, with evidence |
| `install.sh` | Copies the skills into `~/.codex/skills` |

## Quick start

1. Install the slash commands:

   ```bash
   bash install.sh
   ```

2. Restart Codex.
3. Type `/utility` to see the menu, or `/loop <task>` to start the loop.

## Run the demo

```bash
cd demo
bash ../loop/loop.sh
```

The loop stops when the runner reports `DONE:`, after 6 cycles, or after two
consecutive cycles leave `prompt.md` unchanged. `--every 600` gives a
10-minute cadence. See `loop/README.md` for all options and the portable setup
recipe for machines without the router.

## Slash commands

| Command | Model / role |
| --- | --- |
| `/loop <task>` | DeepSeek runs, Luna watches, Sol rewrites |
| `/flash <task>` | `opencode-go/deepseek-v4-flash` |
| `/deepseek <task>` | `opencode-go/deepseek-v4-pro` |
| `/luna <task>` | `gpt-5.6-luna` |
| `/sol <task>` | `gpt-5.6-sol` |
| `/build <task>` | `opencode-go/deepseek-v4-pro` with verification |
| `/utility` | Prints this mapping |

The model slugs assume the local Codex Router catalog. On other machines,
replace them with any model `codex exec -m` can reach.
