import subprocess
import time

def close_process(process: subprocess.Popen):
    if process:
        process.send_signal(subprocess.signal.SIGTERM)
        process.wait(10)
        if process.poll() is None:
            process.kill()



def wait_for_appium_initialization(process: subprocess.Popen, timeout: int):
    start_time = time.time()
    while True:
        output = process.stdout.readline().decode('utf-8').strip()
        if "Appium REST http interface listener started" in output:
            return
        if process.poll() is not None:
            raise RuntimeError("Appium process terminated")
        if time.time() - start_time > timeout:
            raise TimeoutError("Appium initialization timeout")

def main():
    appium_process = subprocess.Popen("appium&", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
    tests_process = subprocess.Popen(tests_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    tests_process.wait()

    close_process(appium_process)
    exit(tests_process.returncode)



if __name__ == "__main__":
    main()