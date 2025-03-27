import subprocess

emulator_name = "emulator-5555"
file_path = "platform_config_template.yaml"

command = f"adb -s {emulator_name} shell getprop emu.uuid"

ret = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
emulator_uuid = ret.stdout.strip()


try:
    with open(file_path, 'r') as file:
        content = file.read()
        format_config = content.format(
            uuid=emulator_uuid,
        )
        print(format_config)

except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)