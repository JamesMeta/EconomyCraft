import subprocess
import time
import threading
import os
import signal
import datetime
import schedule

# Configurable settings
START_COMMAND = ["java", "@user_jvm_args.txt", "@libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt", "nogui"]
#MAX_UPTIME_SECONDS = 48 * 60 * 60  # 48 hours
MAX_UPTIME_SECONDS = 140
RESTART_DELAY_SECONDS = 10  # Short delay between crash and restart
CHECK_INTERVAL_SECONDS = 5  # How often to check if server is still running

# Global variable to hold current server process
current_process = None

def start_server():
    """Start the Minecraft server process and return the process object."""
    print(f"[{datetime.datetime.now()}] Starting Minecraft server...")
    process = subprocess.Popen(
        START_COMMAND, 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, 
        stderr=subprocess.STDOUT, 
        text=True,
        bufsize=1  # Line buffered output
    )
    global current_process
    current_process = process
    return process

def stop_server(process):
    """Gracefully stop the server, with forced termination if needed."""
    if process is None or process.poll() is not None:
        print(f"[{datetime.datetime.now()}] Server is not running.")
        return
    
    print(f"[{datetime.datetime.now()}] Stopping Minecraft server...")
    try:
        process.stdin.write("stop\n")
        process.stdin.flush()
        # Wait up to 120 seconds for clean shutdown
        process.wait(timeout=120)
        print(f"[{datetime.datetime.now()}] Server stopped gracefully.")
    except subprocess.TimeoutExpired:
        print(f"[{datetime.datetime.now()}] Server did not stop gracefully, terminating process...")
        try:
            process.terminate()
            process.wait(timeout=30)
            print(f"[{datetime.datetime.now()}] Server terminated.")
        except subprocess.TimeoutExpired:
            print(f"[{datetime.datetime.now()}] Force killing server...")
            process.kill()
            print(f"[{datetime.datetime.now()}] Server killed.")
    finally:
        global current_process
        current_process = None

def monitor_output(process):
    """Monitor and print the server's output."""
    for line in iter(process.stdout.readline, ''):
        if line.strip():  # Only print non-empty lines
            print(f"[SERVER] {line.strip()}")

def command_input_handler():
    """Read commands from terminal and send them to the server process."""
    print("[MANAGER] Interactive console started. Type commands to send to the server.")
    print("[MANAGER] Type 'exit' to stop the server manager.")
    
    while True:
        try:
            # Read command from terminal
            command = input()
            
            if command.lower() == 'exit':
                print("[MANAGER] Exiting server manager...")
                os._exit(0)  # Force exit the entire program
            
            # Forward command to Minecraft server if it's running
            global current_process
            if current_process and current_process.poll() is None:
                current_process.stdin.write(f"{command}\n")
                current_process.stdin.flush()
            else:
                print("[MANAGER] No running server to send command to.")
                
        except EOFError:
            # Handle EOF (e.g., when input is closed)
            break
        except Exception as e:
            print(f"[MANAGER] Error processing command: {e}")

def server_manager():
    """Main server management loop."""
    # Start the command input thread
    input_thread = threading.Thread(target=command_input_handler, daemon=True)
    input_thread.start()
    
    while True:
        # Start the server
        process = start_server()
        
        # Start monitoring thread
        monitor_thread = threading.Thread(target=monitor_output, args=(process,), daemon=True)
        monitor_thread.start()

        # Track how long the server has been running
        start_time = time.time()
        crashed = False
        
        # Main monitoring loop
        while time.time() - start_time < MAX_UPTIME_SECONDS:
            # Check if the server process has terminated unexpectedly
            if process.poll() is not None:
                print(f"[{datetime.datetime.now()}] Server crashed or stopped unexpectedly.")
                crashed = True
                break
            time.sleep(CHECK_INTERVAL_SECONDS)
        
        # Handle server shutdown based on why we exited the loop
        if crashed:
            # Server crashed - wait briefly then restart
            print(f"[{datetime.datetime.now()}] Waiting {RESTART_DELAY_SECONDS} seconds before restart...")
            time.sleep(RESTART_DELAY_SECONDS)
        else:
            # Server reached max uptime - stop it gracefully then restart
            print(f"[{datetime.datetime.now()}] Server reached maximum uptime of {MAX_UPTIME_SECONDS/3600} hours.")

            start_stop_time = time.time()
            stop_server(process)
            elapsed_stop_time = time.time() - start_stop_time
            print(f"[{datetime.datetime.now()}] Stopped server in {elapsed_stop_time:.2f} seconds.")

            print(f"[{datetime.datetime.now()}] Waiting {MAX_UPTIME_SECONDS} seconds before restart...")
            time.sleep(MAX_UPTIME_SECONDS - elapsed_stop_time)  # Wait before starting a new instance
            
            print(f"[{datetime.datetime.now()}] Restarting server...")

if __name__ == "__main__":
    try:
        print(f"[{datetime.datetime.now()}] Server manager started.")
        
        # Check if we should wait until 6 AM
        current_hour = datetime.datetime.now().hour
        if current_hour < 6:
            print(f"[{datetime.datetime.now()}] Waiting till 6am to start...")
            # Wait until 6 AM to start the server
            while datetime.datetime.now().hour < 6:
                time.sleep(45)  # Check every 45 seconds
        
        print(f"[{datetime.datetime.now()}] Starting server manager...")
        server_manager()
        
    except KeyboardInterrupt:
        print(f"[{datetime.datetime.now()}] Server manager stopped by user.")
        if current_process:
            stop_server(current_process)