import subprocess

emulator_name = "emulator-5554"
file_path = "platform_config_template.yaml"

command = f"echo adb -s {emulator_name} shell getprop qemu.uuid"

ret = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
emulator_udid = ret.stdout
print(f"Emulator udid: {emulator_udid}")


try:
    with open(file_path, 'r') as file:
        content = file.read()
        format_config = content.format(
            udid=emulator_udid,
        )
        print(format_config)

except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)