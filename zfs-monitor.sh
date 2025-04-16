#!/bin/bash

# Path to your Ansible playbook
PLAYBOOK="/root/ansible/zfs_disk_replace.yml"

# Get all ZFS pool names
POOLS=$(zpool list -H -o name)

# Initialize a flag to track if any pool is degraded
RUN_PLAYBOOK=false

for POOL in $POOLS; do
  STATE=$(zpool list -H -o health "$POOL")

  if [[ "$STATE" == "DEGRADED" || "$STATE" == "UNAVAIL" ]]; then
    echo "[$(date)] Pool $POOL is $STATE. Marking for playbook run."
    RUN_PLAYBOOK=true
  else
    echo "[$(date)] Pool $POOL is $STATE. No action needed."
  fi
done

# Run playbook only once if any pool is degraded/unavailable
if [ "$RUN_PLAYBOOK" = true ]; then
  echo "[$(date)] Running Ansible playbook to replace disk(s)..."
  ansible-playbook "$PLAYBOOK"
fi