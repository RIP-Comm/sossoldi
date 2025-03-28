import subprocess
import time
import threading
from typing import IO

outputs: list[subprocess.Popen] = []
mutex = threading.Lock()

def print_outputs():
    while True:
        mutex.acquire(True, 60)
        for output in outputs:
            _stdout = output.stdout
            _stderr = output.stderr
            
            if _stdout.readable():
                line = _stdout.readline().decode("utf-8")
                if line != "":
                    print(line)
            if _stderr.readable():
                line = _stderr.readline().decode("utf-8")
                if line != "":
                    print(line)
        mutex.release()
        
def add_output(output: subprocess.Popen):
    mutex.acquire(True, 60)
    outputs.append(output)
    mutex.release()

def open_process(command: str, add_to_std_output = True) -> subprocess.Popen:
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if add_to_std_output:
        add_output(process)
    return process

def close_process(process: subprocess.Popen):
    if process:
        process.send_signal(subprocess.signal.SIGTERM)
        process.wait(10)
        if process.poll() is None:
            process.kill()

def wait_for_appium_initialization(process: subprocess.Popen, timeout: int):
    start_time = time.time()
    while True:
        if process.poll() is not None:
            raise RuntimeError("Appium process terminated")
        
        output = process.stdout.readline().decode("utf-8").strip()
        print(output)

        if "Appium REST http interface listener started" in output:
            add_output(process)
            return

        if time.time() - start_time > timeout:
            raise TimeoutError("Appium initialization timeout")

def main():
    output_thread = threading.Thread(target=print_outputs, daemon=True)
    output_thread.start()

    appium_process = open_process("appium", False)
    try:
        wait_for_appium_initialization(appium_process, timeout=30)
        print("Appium started successfully")

    except TimeoutError as e:
        print(f"Error: {e}")
        close_process(appium_process)
        exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        if appium_process.poll() is None:
            close_process(appium_process)
        exit(1)


    tests_command = "pytest -s tests --driver Remote --local android"
    tests_process = open_process(tests_command)

    close_process(appium_process)
    threading.Event().wait(5)
    exit(tests_process.returncode)







if __name__ == "__main__":
    main()