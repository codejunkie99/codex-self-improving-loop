import threading
import time


class Counter:
    def __init__(self):
        self.lock = threading.Lock()
        self.value = 0


def worker(counter, iterations):
    for _ in range(iterations):
        with counter.lock:
            current = counter.value
            time.sleep(0.0001)
            counter.value = current + 1


if __name__ == "__main__":
    counter = Counter()
    threads = [
        threading.Thread(target=worker, args=(counter, 200))
        for _ in range(8)
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    print(counter.value)
