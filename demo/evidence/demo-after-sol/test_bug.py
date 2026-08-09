import subprocess
import sys


def main():
    result = subprocess.run(
        [sys.executable, "bug.py"], capture_output=True, text=True
    )
    print(result.stdout, result.stderr)
    assert result.returncode == 0, "bug.py crashed"
    expected = 8 * 200
    actual = int(result.stdout.strip().splitlines()[-1])
    assert actual == expected, f"sync bug: got {actual}, want {expected}"
    print(f"OK counter={actual}")


if __name__ == "__main__":
    main()
