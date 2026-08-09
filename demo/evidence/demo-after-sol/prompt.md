# Task

Fix the synchronization bug in bug.py. Protect each shared-counter
read-modify-write with a `threading.Lock` so concurrent workers cannot lose
updates.

Make the test pass by running:

    python3 test_bug.py

Constraints:
- Keep the same public behavior and output format.
- Do not restructure the program.
- Reply starting with the line DONE: only when `python3 test_bug.py` prints OK
  and exits 0. Otherwise reply with a short status: what changed and what still
  fails.
