#!/bin/bash

. gadget-lib.sh

command=$1
shift

case "$command" in
  "create")
    check_usb_gadget || die
    create_gadget g0
    ;;
  "list")
    list_gadget g0
    ;;
  "mass_storage")
    create_mass_storage g0 "$@"
    ;;
  "remove")
    while [ "$1" != "" ]; do
      remove_function g0 "$1"
      shift
    done
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
    echo Invalid option. Please see README.md >&2
    ;;
esac

