import subprocess
import time
import threading
import sys



def open_process(command: str) -> subprocess.Popen:
    process = subprocess.Popen(command, shell=True, stdout=sys.stdout, stderr=sys.stdout)
    #add_output(process.stdout)
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
        output = process.stdout.readline().decode("utf-8").strip()
        if "Appium REST http interface listener started" in output:
            return
        if process.poll() is not None:
            raise RuntimeError("Appium process terminated")
        if time.time() - start_time > timeout:
            raise TimeoutError("Appium initialization timeout")

def main():
  #  output_thread = threading.Thread(target=print_outputs, daemon=True)
    #output_thread.start()

    appium_process =  open_process("appium")
    try:
        wait_for_appium_initialization(appium_process, timeout=30)
        print("Appium started successfully")

    except TimeoutError as e:
        print(f"Error: {e}")
        close_process(appium_process)
        exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        exit(1)


    tests_command = "pytest -s tests --driver Remote --local android"
    tests_process = open_process(tests_command)
    tests_process.wait()
    
    close_process(appium_process)
    exit(tests_process.returncode)







if __name__ == "__main__":
    main()