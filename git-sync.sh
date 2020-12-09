#!/bin/bash

set -e

SOURCE_REPO=$1
DESTINATION_REPO=$2
SOURCE_BRANCH=${3:-"*"}
DESTINATION_BRANCH=${4:-"*"}

if ! echo $SOURCE_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
    SOURCE_REPO="git@github.com:${SOURCE_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    SOURCE_REPO="https://github.com/${SOURCE_REPO}.git"
  fi
fi

if ! echo $DESTINATION_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
    DESTINATION_REPO="git@github.com:${DESTINATION_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    DESTINATION_REPO="https://github.com/${DESTINATION_REPO}.git"
  fi
fi

echo "SOURCE --> $SOURCE_REPO:$SOURCE_BRANCH"
echo "DESTINATION --> $DESTINATION_REPO:$DESTINATION_BRANCH"

if [[ "$SOURCE_BRANCH" == "*" ]]; then
  SOURCE_BRANCH=".*"
fi

if [[ "$DESTINATION_BRANCH" == "*" ]]; then
  DESTINATION_BRANCH="refs/heads/*"
fi

if [[ -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
  # Clone using source ssh key if provided
  git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/src_rsa" "$SOURCE_REPO" /root/source --origin source && cd /root/source
else
  git clone "$SOURCE_REPO" /root/source --origin source && cd /root/source
fi

git remote add destination "$DESTINATION_REPO"

# Pull all branches references down locally so subsequent commands can see them
git fetch source '+refs/heads/*:refs/heads/*' --update-head-ok

# Print out all branches
# git --no-pager branch -a -vv

if [[ -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
  # Push using destination ssh key if provided
  git config --local core.sshCommand "/usr/bin/ssh -i ~/.ssh/dst_rsa"
fi

SOURCE_BRANCHES=($(git branch -a | grep source/* | grep -v HEAD | sed 's/remotes\/source\///g'))

echo "SOURCE_BRANCHES --> $(
  IFS=,
  echo "${SOURCE_BRANCHES[*]}"
)"

if [[ -n "$COMMIT_USER_EMAIL" && -n "$COMMIT_USER_NAME" ]]; then
  git config --global user.email $COMMIT_USER_EMAIL
  git config --global user.name $COMMIT_USER_NAME
fi

for BRANCH in "${SOURCE_BRANCHES[@]}"; do
  BRANCH_REGEX="($SOURCE_BRANCH)"

  if [[ $BRANCH =~ $BRANCH_REGEX ]]; then
    echo "SYNCING --> $BRANCH"

    git checkout $BRANCH

    if [[ -n "$COMMIT_USER_EMAIL" && -n "$COMMIT_USER_NAME" ]]; then
      # git commit --amend --author="Git Sync <git@sync.git>" --no-edit
      git commit --allow-empty --message="git-sync: $(git log -1 --oneline)"
    fi

    git push destination "${DESTINATION_BRANCH}" --force
  fi
done

if [[ -n "$SYNC_TAGS" ]]; then
  git push destination "refs/tags/*:refs/tags/*" -f
fi
