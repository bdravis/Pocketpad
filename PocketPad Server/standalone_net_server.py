import time
import signal
import sys

from dsu_server import DSU_Server  # existing class

def main():
    server = DSU_Server()  # default port (26760)
    server.start()
    print(f"Network server listening on port {server.port}  (Ctrl‑C to stop)")
    # Block until Ctrl‑C
    def _shutdown(signum, frame):
        print("\nStopping network server…")
        server.stop()
        sys.exit(0)

    signal.signal(signal.SIGINT, _shutdown)
    # Sleep in a loop
    while True:
        time.sleep(3600)

if __name__ == "__main__":
    main()
