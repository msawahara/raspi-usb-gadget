#!/bin/bash

MOD_DWC2="dwc2"
MOD_LIBCOMPOSITE="libcomposite"
CONFIGFS_USB_GADGET="/sys/kernel/config/usb_gadget"

function die () {
  echo $@
  exit 1
}

function load_module () {
  MOD=$1

  if lsmod | cut -d' ' -f1 | grep -e "^${MOD}\$" > /dev/null 2>&1; then
    # module is loaded
    return 0
  fi

  # module is not loaded
  modprobe ${MOD}

  return $?
}

function check_usb_gadget () {
  load_module ${MOD_DWC2} || die "Cannot load module"
  load_module ${MOD_LIBCOMPOSITE} || die "Cannot load module"

  if [ ! -d ${CONFIGFS_USB_GADGET} ]; then
    echo "USB gadget directory not found"
    return 1
  fi

  return 0
}

function create_mass_storage() {
  GADGET_NAME="$1"
  IMAGE_FILE="$2"
  shift 2

  FUNCTION_TYPE="mass_storage"
  FUNCTION_NAME="0"

  create_function ${GADGET_NAME} ${FUNCTION_TYPE} ${FUNCTION_NAME}

  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"
  CONFIG_DIR="${GADGET_DIR}/configs/c.1"
  FUNCTION_DIR="${GADGET_DIR}/functions/${FUNCTION_TYPE}.${FUNCTION_NAME}"

  echo ${IMAGE_FILE} > ${FUNCTION_DIR}/lun.0/file

  while [ "$1" != "" ];
  do
    case "$1" in
      "removable")
        echo 1 > ${FUNCTION_DIR}/lun.0/removable
        ;;
      "ro")
        echo 1 > ${FUNCTION_DIR}/lun.0/ro
        ;;
      "cdrom")
        echo 1 > ${FUNCTION_DIR}/lun.0/cdrom
        ;;
      *)
        echo "invalid option: $1"
        ;;
    esac
    shift
  done

  mkdir -p ${CONFIG_DIR}

  if [ ! -d "${CONFIG_DIR}/${FUNCTION_TYPE}.${FUNCTION_NAME}" ]; then
    ln -s ${FUNCTION_DIR} ${CONFIG_DIR}/
  fi

  return
}

function create_function () {
  GADGET_NAME="$1"
  FUNCTION_TYPE="$2"
  FUNCTION_NAME="$3"

  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"
  FUNCTION_DIR="${GADGET_DIR}/functions/${FUNCTION_TYPE}.${FUNCTION_NAME}"

  mkdir -p ${FUNCTION_DIR}

  return
}

function remove_function () {
  GADGET_NAME="$1"
  FUNCTION_TYPE="$2"
  FUNCTION_NAME="$3"

  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"
  FUNCTION_DIR="${GADGET_DIR}/functions/${FUNCTION_TYPE}.${FUNCTION_NAME}"

  rm -f "${GADGET_DIR}/configs/c.1/${FUNCTION_TYPE}.${FUNCTION_NAME}"
  rmdir "${FUNCTION_DIR}"

  return
}

function create_gadget () {
  GADGET_NAME="$1"
  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"

  mkdir -p ${GADGET_DIR}

  echo "64"     > ${GADGET_DIR}/bMaxPacketSize0
  echo "0x1d6b" > ${GADGET_DIR}/idVendor        # Vendor ID: The Linux Foundation
  echo "0x0104" > ${GADGET_DIR}/idProduct       # Product ID: Multifunction Composite Gadget
  echo "0x0200" > ${GADGET_DIR}/bcdUSB          # USB version: USB 2.0
  echo "0x0100" > ${GADGET_DIR}/bcdDevice       # Device version: v1.0.0

  LANG_ID="0x409" # LANG=en_US
  PRODUCT_INFO_DIR="${GADGET_DIR}/strings/${LANG_ID}"
  mkdir -p ${PRODUCT_INFO_DIR}

  DEVICE_SERIALNUMBER="00000000"
  DEVICE_MANUFACTURER="The Linux Foundation"
  DEVICE_PRODUCT_NAME="Generic USB Device"

  echo ${DEVICE_SERIALNUMBER} > ${PRODUCT_INFO_DIR}/serialnumber
  echo ${DEVICE_MANUFACTURER} > ${PRODUCT_INFO_DIR}/manufacturer
  echo ${DEVICE_PRODUCT_NAME} > ${PRODUCT_INFO_DIR}/product

  return
}

function remove_gadget () {
  GADGET_NAME="$1"
  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"
  CONFIG_DIR="${GADGET_DIR}/configs/c.1"

  disable_gadget "${GADGET_NAME}"

  rmdir ${CONFIG_DIR}
  rmdir ${GADGET_DIR}/strings/*
  rmdir ${GADGET_DIR}

  return
}

function enable_gadget () {
  GADGET_NAME="$1"
  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"

  ls /sys/class/udc > ${GADGET_DIR}/UDC

  return
}

function disable_gadget () {
  GADGET_NAME="$1"
  GADGET_DIR="${CONFIGFS_USB_GADGET}/${GADGET_NAME}"

  echo "" > ${GADGET_DIR}/UDC

  return
}