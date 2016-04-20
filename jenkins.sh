#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
cd "$WORKSPACE"
logger -p INFO -t jenkins "DEPLOYMENT: ${JOB_NAME} ${BUILD_NUMBER} ${TARGET_APPLICATION} ${TAG} (${BUILD_URL})"
git clone git@github.gds:gds/alphagov-deployment.git
cd $TARGET_APPLICATION
if [ -d "../alphagov-deployment/${TARGET_APPLICATION}" ]; then
  mkdir secrets
  cp -r ../alphagov-deployment/$TARGET_APPLICATION/* secrets
fi

if [ -e "deploy.sh" ]; then
  echo "---> Found deploy.sh, running 'sh -e deploy.sh'" >&2
  exec sh -e deploy.sh
else
  echo "---> No deploy.sh found, running 'bundle exec cap \"${DEPLOY_TASK}\"'" >&2
  exec bundle exec cap "$DEPLOY_TASK"
fi
