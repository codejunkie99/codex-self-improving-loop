# Task

Fix the synchronization bug in bug.py. The shared counter loses updates
because multiple threads read-modify-write it without coordination.

Make the test pass by running:

    python3 test_bug.py

Constraints:
- Keep the same public behavior and output format.
- Do not restructure the program.
- Reply starting with the line DONE: only when `python3 test_bug.py` prints OK
  and exits 0. Otherwise reply with a short status: what you changed and what
  still fails.
