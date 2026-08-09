
## Cycle 01
### run (2026-08-09T13:12:17Z)
DONE: added a `threading.Lock` to `Counter` and held it around each read-modify-write in `worker`, preserving the same behavior and output. `python3 test_bug.py` prints `OK counter=1600` and exits 0.