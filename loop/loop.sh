#!/usr/bin/env bash
#
# loop.sh - self-improving loop
# runner (DeepSeek) runs prompt.md, watcher (Luna) grades, rewriter (Sol) rewrites.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODECX="${CODEX_BIN:-codex}"

# ---- defaults -----------------------------------------------------------
RUNNER_MODEL="${RUNNER_MODEL:-opencode-go/deepseek-v4-flash}"
WATCHER_MODEL="${WATCHER_MODEL:-gpt-5.6-luna}"
REWRITER_MODEL="${REWRITER_MODEL:-gpt-5.6-sol}"
MAX_CYCLES="${MAX_CYCLES:-6}"
NO_PROGRESS_LIMIT="${NO_PROGRESS_LIMIT:-2}"
EVERY="${EVERY:-0}"
UTILITY="${UTILITY:-}"
WORKDIR="${WORKDIR:-$(pwd)}"
WATCHER_FILE="${WATCHER_FILE:-$HERE/watcher.md}"
REWRITER_FILE="${REWRITER_FILE:-$HERE/rewriter.md}"
CYCLES_DIR="${CYCLES_DIR:-$HERE/cycles}"

usage() {
  cat <<'EOF'
Usage: loop.sh [options]
  --runner-model SLUG    model that runs the task (default: opencode-go/deepseek-v4-flash)
  --watcher-model SLUG   model that grades the run (default: gpt-5.6-luna)
  --rewriter-model SLUG  model that rewrites prompt.md (default: gpt-5.6-sol)
  --max-cycles N         stop after N cycles (default: 6)
  --no-progress-stop N   stop after N cycles with no prompt change (default: 2)
  --every SECONDS        wait between cycles (default: 0)
  --utility NAME         pick models from the utility menu (fast, deep, luna, sol, build)
  --workdir DIR          directory holding prompt.md and log.md (default: current dir)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runner-model) RUNNER_MODEL="$2"; shift 2 ;;
    --watcher-model) WATCHER_MODEL="$2"; shift 2 ;;
    --rewriter-model) REWRITER_MODEL="$2"; shift 2 ;;
    --max-cycles) MAX_CYCLES="$2"; shift 2 ;;
    --no-progress-stop) NO_PROGRESS_LIMIT="$2"; shift 2 ;;
    --every) EVERY="$2"; shift 2 ;;
    --utility) UTILITY="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

case "$UTILITY" in
  "")
    ;;
  fast|flash)
    RUNNER_MODEL="opencode-go/deepseek-v4-flash"
    ;;
  deep|deepseek)
    RUNNER_MODEL="opencode-go/deepseek-v4-pro"
    ;;
  luna|grade|watch)
    WATCHER_MODEL="gpt-5.6-luna"
    ;;
  sol|review|rewrite)
    REWRITER_MODEL="gpt-5.6-sol"
    ;;
  build|implement)
    RUNNER_MODEL="opencode-go/deepseek-v4-pro"
    ;;
  *)
    echo "unknown utility: $UTILITY" >&2
    usage
    exit 2
    ;;
esac

prompt="$WORKDIR/prompt.md"
log="$WORKDIR/log.md"
if [[ ! -f "$prompt" ]]; then
  echo "missing $prompt (copy prompt.md into your project and write the task there)" >&2
  exit 2
fi
[[ -f "$log" ]] || : > "$log"
mkdir -p "$CYCLES_DIR"

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    md5sum "$1" | awk '{print $1}'
  fi
}

codex_exec() {
  local model="$1" sandbox="$2" input="$3" output="$4"
  "$CODECX" exec -m "$model" -s "$sandbox" -C "$WORKDIR" \
    --skip-git-repo-check --ephemeral -o "$output" - < "$input"
}

printf 'Loop start\n  workdir=%s\n  runner=%s\n  watcher=%s\n  rewriter=%s\n  max_cycles=%s no_progress_stop=%s every=%s\n' \
  "$WORKDIR" "$RUNNER_MODEL" "$WATCHER_MODEL" "$REWRITER_MODEL" \
  "$MAX_CYCLES" "$NO_PROGRESS_LIMIT" "$EVERY"

cycle=1
no_progress_streak=0
last_progress=0
status="max-cycles"

while (( cycle <= MAX_CYCLES )); do
  tag="$(printf '%02d' "$cycle")"
  run_out="$CYCLES_DIR/cycle-$tag-run.md"
  watch_out="$CYCLES_DIR/cycle-$tag-watch.md"
  rewrite_out="$CYCLES_DIR/cycle-$tag-rewrite.md"
  before="$(sha256_file "$prompt")"

  printf '\n=== cycle %d/%d ===\n' "$cycle" "$MAX_CYCLES"
  printf '[runner] %s running task...\n' "$RUNNER_MODEL"
  codex_exec "$RUNNER_MODEL" workspace-write "$prompt" "$run_out"

  {
    printf '\n## Cycle %s\n### run (%s)\n' "$tag" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    cat "$run_out"
  } >> "$log"

  if grep -qiE '^DONE:' "$run_out"; then
    status="done"
    last_progress="$cycle"
    printf '[runner] reported DONE: task complete.\n'
  else
    printf '[watcher] %s grading...\n' "$WATCHER_MODEL"
    {
      cat "$WATCHER_FILE"
      printf '\n--- current prompt.md ---\n'
      cat "$prompt"
      printf '\n--- recent log.md ---\n'
      tail -n 120 "$log"
    } > /tmp/loop-watcher-input.md
    codex_exec "$WATCHER_MODEL" read-only /tmp/loop-watcher-input.md "$watch_out"
    {
      printf '\n### watch (%s)\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      cat "$watch_out"
    } >> "$log"

    printf '[rewriter] %s rewriting prompt.md...\n' "$REWRITER_MODEL"
    {
      cat "$REWRITER_FILE"
      printf '\n--- current prompt.md ---\n'
      cat "$prompt"
      printf '\n--- recent log.md ---\n'
      tail -n 160 "$log"
    } > /tmp/loop-rewriter-input.md
    codex_exec "$REWRITER_MODEL" workspace-write /tmp/loop-rewriter-input.md "$rewrite_out"
    {
      printf '\n### rewrite (%s)\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      cat "$rewrite_out"
    } >> "$log"
  fi

  if [[ "$status" == "done" ]]; then
    break
  fi

  after="$(sha256_file "$prompt")"
  if [[ "$before" == "$after" ]]; then
    no_progress_streak=$((no_progress_streak + 1))
    printf '[loop] no prompt change (streak %d)\n' "$no_progress_streak"
  else
    no_progress_streak=0
    last_progress="$cycle"
    printf '[loop] prompt.md changed (last progress cycle %d)\n' "$cycle"
  fi

  if (( no_progress_streak >= NO_PROGRESS_LIMIT )); then
    status="no-progress"
    printf '[loop] stopping: %d consecutive cycles without progress\n' "$no_progress_streak"
    break
  fi
  if (( EVERY > 0 )) && (( cycle < MAX_CYCLES )); then
    printf '[loop] waiting %s seconds...\n' "$EVERY"
    sleep "$EVERY"
  fi
  cycle=$((cycle + 1))
done

cat > "$CYCLES_DIR/state.json" <<EOF
{
  "status": "$status",
  "cycles_run": $cycle,
  "last_progress_cycle": $last_progress,
  "runner_model": "$RUNNER_MODEL",
  "watcher_model": "$WATCHER_MODEL",
  "rewriter_model": "$REWRITER_MODEL"
}
EOF

printf '\n=== loop finished: %s after %d cycle(s) ===\n' "$status" "$cycle"
echo "log: $log"
echo "state: $CYCLES_DIR/state.json"
