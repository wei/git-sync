#!/bin/sh

set -e

if [[ -n "$SSH_PRIVATE_KEY" ]]; then
  mkdir -p /root/.ssh
  echo "$SSH_PRIVATE_KEY" | sed 's/\\n/\n/g' >/root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

if [[ -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
  mkdir -p /root/.ssh
  echo "$SOURCE_SSH_PRIVATE_KEY" | sed 's/\\n/\n/g' >/root/.ssh/src_rsa
  chmod 600 /root/.ssh/src_rsa
fi

if [[ -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
  mkdir -p /root/.ssh
  echo "$DESTINATION_SSH_PRIVATE_KEY" | sed 's/\\n/\n/g' >/root/.ssh/dst_rsa
  chmod 600 /root/.ssh/dst_rsa
fi

mkdir -p ~/.ssh
cp /root/.ssh/* ~/.ssh/ 2>/dev/null || true

sh -c "/git-sync.sh $*"
