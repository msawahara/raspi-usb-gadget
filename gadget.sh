#!/bin/bash

. gadget-lib.sh

command=$1
shift

case "$command" in
  "create")
    check_usb_gadget || die
    create_gadget g0
    ;;
  "mass_storage")
    create_mass_storage g0 "$@"
    ;;
  "remove")
    remove_function g0 "$@"
    ;;
  "enable")
    enable_gadget g0
    ;;
  "disable")
    disable_gadget g0
    ;;
  "terminate")
    remove_gadget g0
    ;;
  * )
    echo error
    ;;
esac

