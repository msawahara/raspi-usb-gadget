# raspi-usb-gadget
Tools for use Raspberry Pi as a USB gadget

## Example
start
```shell
# ./gadget.sh create
# ./gadget.sh mass_storage /home/pi/image.bin cdrom ro
# ./gadget.sh enable
```

stop
```shell
# ./gadget.sh disable
# ./gadget.sh remove mass_storage.0
# ./gadget.sh termiante
```

## Usage
```shell
# ./gadget.sh create
# ./gadget.sh list
# ./gadget.sh mass_storage <image file> [options]
# ./gadget.sh keyboard
# ./gadget.sh mouse
# ./gadget.sh get_hid_device <name>
# ./gadget.sh remove <name1> [name2] ...
# ./gadget.sh enable
# ./gadget.sh disable
# ./gadget.sh terminate
```

### mass_storage
```
# ./gadget.sh mass_storage <image file> [options] 
```

- options
  - removable
  - ro (read only)
  - cdrom
  - nofua (no force unit access)
