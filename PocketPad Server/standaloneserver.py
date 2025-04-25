import sys
import subprocess



def run_bluetooth():
    subprocess.call([sys.executable, "standalone_bt_server.py"])

def run_network():
    subprocess.call([sys.executable, "standalone_net_server.py"])

def main():
    print("Welcome to PocketPad standalone!")
    print()
    print("Select which server to run:")
    print("  1) Bluetooth server")
    print("  2) Network server")
    print("  3) Exit")
    choice = input("Choose an option [1–3]: ").strip()

    if choice == "1":
        run_bluetooth()
    elif choice == "2":
        run_network()
    else:
        print("Goodbye!")
        sys.exit(0)

if __name__ == "__main__":
    main()
