import os
import queue
import threading

logs = queue.Queue()

file_queue = queue.Queue()
content_queue = queue.Queue()

start_writing_count = 0
start_writing_lock = threading.Lock()
start_writing_condition = threading.Condition(start_writing_lock)

stdout_lock = threading.Lock()
stdout_condition = threading.Condition(stdout_lock)

readers_done = threading.Event()

def walk(path):
    global file_queue
    for root, _, filenames in os.walk(path):
        for name in filenames:
            if name.endswith(".txt"):
                file_queue.put(os.path.join(root, name))

def writer():
    global content_queue, start_writing_condition, start_writing_count, readers_done, logs

    with start_writing_condition:
        while start_writing_count < 2:
            start_writing_condition.wait()

    while True:
        try:
            file_content = content_queue.get(timeout=0.1)
        except queue.Empty:
            if readers_done.is_set():
                break
            continue


        print_string = ""
        for x in file_content:
            if x.isalnum():
                print_string = print_string + x

        logs.put(f'Thread Id {threading.get_ident()} is currently writing at standard output.')
        with stdout_condition:
            print(print_string)

def reader():
    global file_queue, content_queue, start_writing_count, start_writing_condition, logs
    while True:
        try:
            path = file_queue.get(block = False)
        except queue.Empty:
            break

        logs.put(f"Thread Id {threading.get_ident()} is currently working on file {path}")
        file = open(path, 'r')
        string = file.read()
        file.close()
        content_queue.put(string)

        with start_writing_condition:
            start_writing_count += 1
            if start_writing_count >= 2:
                start_writing_condition.notify_all()


def main():
    global readers_done

    path = './Folder1'
    n = 2
    m = 2

    walk(path)
    readers = []
    writers = []
    for i in range(n):
        readers.append(threading.Thread(target = reader))
        readers[i].start()
    for i in range(m):
        writers.append(threading.Thread(target = writer))
        writers[i].start()

    for i in range(n):
        readers[i].join()
    readers_done.set()
    for i in range(m):
        writers[i].join()

    print()
    while not logs.empty():
        print(logs.get())
if __name__ == "__main__":
    main()