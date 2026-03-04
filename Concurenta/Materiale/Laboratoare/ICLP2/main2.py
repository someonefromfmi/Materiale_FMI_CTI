import queue
import threading
import time

buffer_size = 2

buffer = queue.Queue(buffer_size)
buffer_count = 0
buffer_lock = threading.Lock()
buffer_lock_condition = threading.Condition(buffer_lock)

producers_done = threading.Event()

def producer():
    global buffer, buffer_lock_condition, buffer_count
    while True:
        with buffer_lock_condition:
            buffer_lock_condition.wait_for(lambda: buffer_count < buffer_size)
            buffer_count += 1
        time.sleep(3000)
        buffer.put([])

def consumer():
    global buffer, buffer_lock_condition, buffer_count, producers_done
    while True:
        try:
            _ = buffer.get(timeout=0.1)
            with buffer_lock_condition:
                buffer_count -= 1
                buffer_lock_condition.notify()
        except queue.Empty:
            if producers_done.is_set():
                break
            continue
        print("consumed")













