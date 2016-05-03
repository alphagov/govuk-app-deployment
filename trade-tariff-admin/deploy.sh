#!/bin/sh
if [ -z "${DEPLOY_TASK}" ] ; then
  echo "Failing because DEPLOY_TASK environment variable not set."
  exit 1
fi
exec bundle exec cap ${DEPLOY_TASK}
