# Self-improving loop

Three models, two role files, one driver. DeepSeek runs the task from
`prompt.md`, Luna grades each run, Sol rewrites `prompt.md`, and the cycle
repeats until the task is done. The prompt file is the product, everything else
is plumbing.

## How it works

1. DeepSeek reads `prompt.md` and does the task in your project directory.
2. The run is appended to `log.md`.
3. Luna reads `prompt.md` plus `log.md` and grades the run: GOAL, KEPT,
   WASTED, FAILED, NEXT.
4. Sol reads both files, applies the NEXT note, and rewrites `prompt.md` in
   place (never more than 20% larger).
5. The loop stops when the runner reports `DONE:`, when the max cycle count is
   hit, or when two consecutive cycles leave `prompt.md` unchanged.

## How to set it up (any machine)

Requirements: the Codex CLI (`codex exec`) and two or three models reachable
with `-m`. On this Mac the router slugs below are already configured.

1. Copy this folder into your project.
2. Copy `prompt.md` to the project root and replace the task text.
3. Run from the project directory:

   ```bash
   bash /path/to/self-improving-loop/loop.sh
   ```

4. Add `--every 600` when you want one cycle every 10 minutes.

The runner needs write access to your project, so the default sandbox is
`workspace-write`. Luna runs read-only. Sol needs write access only because it
rewrites `prompt.md`.

## Utility menu

Mention a utility name instead of configuring models:

| Utility | Model |
| --- | --- |
| `fast` / `flash` | `opencode-go/deepseek-v4-flash` |
| `deep` / `deepseek` | `opencode-go/deepseek-v4-pro` |
| `luna` / `grade` / `watch` | `gpt-5.6-luna` |
| `sol` / `review` / `rewrite` | `gpt-5.6-sol` |
| `build` / `implement` | `opencode-go/deepseek-v4-pro` |

Example: `bash loop.sh --utility fast --utility sol`

## Slash commands

Enabled skills appear in the Codex slash command list, so these are available
in the composer:

| Slash command | What it does |
| --- | --- |
| `/loop <task>` | Start the self-improving loop for the task |
| `/flash <task>` | Run the task on DeepSeek V4 Flash |
| `/deepseek <task>` | Run the task on DeepSeek V4 Pro |
| `/luna <task>` | Run the task on Luna (watch / grade / worker) |
| `/sol <task>` | Run the task on Sol (review / rewrite) |
| `/build <task>` | Implement and verify with DeepSeek V4 Pro |
| `/utility` | Print the utility-to-model menu |

The `loop` skill lives at `~/.codex/skills/loop/`; the utility skills live
alongside it in `~/.codex/skills/`.

## Options

```text
--runner-model SLUG    default opencode-go/deepseek-v4-flash
--watcher-model SLUG   default gpt-5.6-luna
--rewriter-model SLUG  default gpt-5.6-sol
--max-cycles N         default 6
--no-progress-stop N   default 2
--every SECONDS        default 0
--utility NAME         utility menu lookup
--workdir DIR          project holding prompt.md and log.md
```

Cycle artifacts land in `cycles/` and the final state in `cycles/state.json`.

## The 3-file recipe from the diagram

The diagram's setup was: paste the two role files to your agent, say "run this
as a /loop automation". Here those two files are `watcher.md` and
`rewriter.md`; the third file is `prompt.md` (your task), and `loop.sh` is the
automation that wires them together. On this Mac you can instead just say
`/loop start <task>` in Codex and the `loop` skill runs this driver for you.
