#!/bin/bash
set -e

# Hugepages
if [[ $(lscpu | grep x86_64) ]]; then
sudo sysctl -w vm.nr_hugepages=512
sudo mkdir -p /mnt/hugepages
sudo mount -t hugetlbfs -o pagesize=2M none /mnt/hugepages
cat /proc/meminfo | grep Huge
fi

# CI Variables
core_masks=("0x3")
modes=("t")
declare -A apps

# Example Apps
apps+=(["timer_hello"]="" ["timer_test"]="")
apps+=(["api_hooks"]="")
apps+=(["dispatcher_callback"]="")
apps+=(["error"]="")
apps+=(["event_group_abort"]="" ["event_group_assign_end"]="" ["event_group"]=""  ["event_group_chaining"]="")
apps+=(["fractal"]="")
apps+=(["hello"]="")
apps+=(["queue_group"]="")
apps+=(["ordered"]="")
apps+=(["queue_types_ag"]="")
apps+=(["queue_types_local"]="")

# Performance Apps
apps+=(["atomic_processing_end"]="" ["loop"]="" ["pairs"]="" ["queue_groups"]="")
apps+=(["queues"]="" ["queues_local"]="" ["queues_unscheduled"]=""  ["send_multi"]="")

# Path for Apps
for dir in $(find programs -maxdepth 2 -type d); do
  for file in $(find ${dir} -type f -printf "%f\n"); do
    if [[ -n ${apps["${file}"]+1} ]]; then
      if [[ -f "${dir}/${file}" && -x "${dir}/${file}" ]]; then
        apps+=(["${file}"]="${PWD}/${dir}/${file}")
      fi
    fi
  done
done

# Robot Tests
for app in ${!apps[@]}; do
  for ((i=0; i<${#core_masks[@]}; i++)); do
    for ((j=0; j<${#modes[@]}; j++)); do
      sudo robot --variable application:"${apps[${app}]}" \
                 --variable core_mask:"${core_masks[$i]}" \
                 --variable mode:"${modes[$j]}" \
                 --log NONE --report NONE --output NONE \
                 ${PWD}/ci/${app}.robot
    done
  done
done
