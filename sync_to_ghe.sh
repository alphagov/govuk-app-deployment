#!/bin/bash

# This script pushes the deployed version of an application with
# code hosted on public GitHub to a repository of the same name
# on GitHub Enterprise.

# We do this so that we can deploy applications when public GitHub
# is unavailable.

# This script is triggered after a production deployment so that only
# trusted code is pushed to GitHub Enterprise.

set -e

# .rsync_cache is the directory where Capistrano clones code to from
# GitHub during deployment

TARGET_APPLICATION_LOCATION=$TARGET_APPLICATION_GIT_REPO/.rsync_cache
if ! cd "$TARGET_APPLICATION_LOCATION"; then
  echo ">> The .rsync_cache folder doesn't exist. This app might not be deployed using Capistrano" >&2
  exit 0
fi


# Sync only github.com/alphagov repositories not github.digital.cabinet-office.gov.uk/gds repositories
TARGET_APPLICATION_GIT_URL=$(git config --get remote.origin.url)
if echo $TARGET_APPLICATION_GIT_URL | grep 'github.digital.cabinet-office.gov.uk'; then
  echo ">> We don't backup GitHub Enterprise repos using this script" >&2
  exit 0
fi

# Given git URLs of the form:
#
#   TARGET_APPLICATION_GIT_URL=https://github.com/alphagov/whitehall.git
# or
#   TARGET_APPLICATION_GIT_URL=git@github.com:alphagov/whitehall.git
#
# This variable munging should return:
#   TARGET_APPLICATION_REPO_NAME=whitehall
#
# Strip off the .git from the end of the repo
TEMPTARGET=${TARGET_APPLICATION_GIT_URL%%.git}
# Strip of everything up to and including the last slash
TARGET_APPLICATION_REPO_NAME=${TEMPTARGET##*/}

# Create repo if not present in github.digital.cabinet-office.gov.uk
if ! gh-repo gds:gds-production-backup/"$TARGET_APPLICATION_REPO_NAME" get >/dev/null; then
  echo ">> Creating an application in github.digital.cabinet-office.gov.uk"
  if ! (gh-repo gds:gds-production-backup/"$TARGET_APPLICATION_REPO_NAME" create >/dev/null); then
    echo ">> [FAILURE] Repository could not be created"
    exit 1
  fi
fi

# Pushing to remote gitgub.gds/gds-production-backup endpoint
cd "$TARGET_APPLICATION_LOCATION"
if ! git remote | grep -q failover ; then
  git remote add failover git@github.digital.cabinet-office.gov.uk:gds-production-backup/"$TARGET_APPLICATION_REPO_NAME".git
fi
git push -f failover deploy:master
echo "Backed up ${TARGET_APPLICATION_REPO_NAME} successfully"
