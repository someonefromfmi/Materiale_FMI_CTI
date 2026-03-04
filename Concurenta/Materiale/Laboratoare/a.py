import multiprocessing
import os
import time
import signal
import sys

def heavy_calculation(process_id):
    """
    Performs an infinite loop of heavy floating-point arithmetic 
    to maximize CPU usage on a specific core.
    """
    print(f"Process {process_id} started on PID {os.getpid()}")
    while True:
        # Complex floating point math is CPU intensive
        _ = 987654321.12345 * 123456789.98765
        _ = 2 ** 100

def signal_handler(sig, frame):
    """Handles the exit signal to close cleanly."""
    print("\nStopping stress test... cooling down.")
    sys.exit(0)

if __name__ == "__main__":
    # Register the signal handler for Ctrl+C
    signal.signal(signal.SIGINT, signal_handler)

    # Determine the number of available CPU cores
    cpu_count = os.cpu_count()
    
    print("=" * 40)
    print(f"BATTERY DRAINER / CPU STRESS TEST")
    print(f"Detected {cpu_count} CPU cores.")
    print("Starting intensive tasks on all cores...")
    print("Press Ctrl+C to stop.")
    print("=" * 40)

    # Create a list to hold the processes
    processes = []

    try:
        # Spawn a process for each CPU core
        for i in range(cpu_count):
            p = multiprocessing.Process(target=heavy_calculation, args=(i,))
            processes.append(p)
            p.start()

        # Keep the main process alive while workers run
        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        # This block catches Ctrl+C if the signal handler doesn't catch it immediately
        print("\nStopping processes...")
        for p in processes:
            p.terminate()
            p.join()
        print("Stopped.")