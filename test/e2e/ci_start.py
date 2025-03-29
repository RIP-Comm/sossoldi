import subprocess
import time
import threading
import sys

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

def open_process(command: str, add_to_std_output = True, direct_outputs_stdout = False) -> subprocess.Popen[bytes]:

    _stdout = subprocess.PIPE
    if direct_outputs_stdout:
        _stdout = sys.stdout
    
    process = subprocess.Popen(command, shell=True, stdout=_stdout, stderr=_stdout)
    
    if add_to_std_output:
        add_output(process)
    return process

def close_process(process: subprocess.Popen[bytes]):
    if process:
        process.send_signal(subprocess.signal.SIGTERM)
        process.wait(10)
        ret_code = process.poll()
        if ret_code is None:
            process.kill()
        return ret_code

def wait_for_appium_initialization(process: subprocess.Popen, timeout: int):
    start_time = time.time()
    while True:
        if process.poll() is not None:
            raise RuntimeError("Appium process terminated")
        
        output = process.stdout.readline().decode("utf-8").strip()

        sys.stdout.write(output + "\n")
        sys.stdout.flush()

        if "Appium REST http interface listener started" in output:
            sys.stdout.writelines(process.stdout.readlines())
            sys.stdout.writelines(process.stderr.readlines())
            sys.stdout.write("Appium started successfully\n")
            sys.stdout.flush()
            add_output(process)
            return

        if time.time() - start_time > timeout:
            raise TimeoutError("Appium initialization timeout")

def main():
    output_thread = threading.Thread(target=print_outputs, daemon=True)
    output_thread.start()

    appium_process = open_process("appium", False, False)
    try:
        wait_for_appium_initialization(appium_process, timeout=30)

    except Exception as e:
        print(f"Unexpected error: {e}")
        if appium_process:
            close_process(appium_process)
        exit(1)


    tests_command = "pytest -s tests --driver Remote --local android"
    tests_process = open_process(str(tests_command), add_to_std_output=False, direct_outputs_stdout=True)
    tests_process.wait()

    close_process(appium_process)
    threading.Event().wait(5)

    print("Tests completed, return value:", tests_process.returncode)
    exit(tests_process.returncode)







if __name__ == "__main__":
    main()