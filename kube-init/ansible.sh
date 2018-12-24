#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False

argv1=$1
date=$(date '+%Y-%m-%d-%H%M%S')
logfile=ansible-$date.log


_play( ) {
  rm -rf ~/.ssh/known_hosts
  ansible-playbook -i "$argv1" playbook.yml -vv 2>&1 | tee -a $logfile
}

_help( ) {
    echo "Usage : ansible.sh { inventory_file_path }"
    exit 1
}

case ${1} in
    help|-h|--help|usage|--usage)
	   _help
      ;;
    *)
      _play
      ;;
esac
