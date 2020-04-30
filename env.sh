#!/bin/bash
set -e

# Travis Ubuntu
if [[ $(cat /etc/os-release | grep Ubuntu) ]]; then
  # x86_64
  if [[ $(lscpu | grep x86_64) ]]; then
    # Hugepages
    sudo sysctl -w vm.nr_hugepages=512
    cat /proc/meminfo | grep Huge
  fi

  # aarch64
  if [[ $(lscpu | grep aarch64) ]]; then
    # No Hugepages
    # https://travis-ci.community/t/huge-pages-support-within-lxd/5615/2
    echo "WARNING: NO HUGE PAGES"

    # CPU Hz
    # https://travis-ci.community/t/what-machine-s-does-travis-use-for-arm64/5579
    echo "WARNING: CPU Hz FROM ODP CONFIG FILE"
  fi
fi
