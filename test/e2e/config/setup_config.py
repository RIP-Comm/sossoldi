import subprocess

emulator_name = "android-emulator"
file_path = "platform_config_template.yaml"
command = f"adb -s {emulator_name} shell getprop emu.uuid"
exception_raised = False

ret = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
emulator_uuid = ret.stdout.strip()

try:
    with open(file_path, 'r') as file:
        content = file.read()
        format_config = content.format(
            uuid=emulator_uuid,
        )
        print(format_config)
except FileNotFoundError:
    print(f"The file at {file_path} was not found.")
    exception_raised = True
except Exception as e:
    print(f"An error occurred: {e}")
    exception_raised = True

if exception_raised:
    print("Can't setup the config file, aborting.")
    exit(1)