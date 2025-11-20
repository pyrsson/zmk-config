# ZMK Keyboard Configuration

This is a ZMK firmware configuration for the Lotus58 BLE split keyboard.

I make no guarantees that this configuration will work for you as-is; you may need to adjust settings to fit your specific hardware revision or personal preferences.

I've only been building locally but it should be usable with the ZMK github actions workflow as well.

Based a lot of this on the nrf52840 based boards in the ZMK repository.

## Building locally

### Using the build script

The project includes a build script that uses Podman to create a reproducible build environment:

You do need to build the ZMK devcontainer first.

```bash
git clone https://github.com/zmkfirmware/zmk.git
cd zmk
podman build -t zmk-build -f Dockerfile .devcontainer
```

Then you can use the `build.sh` script to build the firmware:

```bash
# Build both halves
./build.sh

# Build only left half
./build.sh left

# Build only right half
./build.sh right

# Build settings reset firmware
./build.sh reset
```

The script will generate `.uf2` files in the current directory:

- `zmk-left.uf2` - Left half firmware
- `zmk-right.uf2` - Right half firmware
- `zmk-settings-reset.uf2` - Settings reset firmware

