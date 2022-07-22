#!/bin/bash -x

bundle config set --local path "${HOME}/bundles/${JOB_NAME}"
bundle config set --local deployment "true"
bundle install

cd "$WORKSPACE"

logger -p INFO -t jenkins "DEPLOYMENT: ${JOB_NAME} ${BUILD_NUMBER} ${TARGET_APPLICATION} ${TAG} (${BUILD_URL})"

if [ $(echo $DEPLOY_TASK | grep docker) ] ; then
  cd "docker_${TARGET_APPLICATION}"
  echo "---> Deploying docker application"
  exec bundle exec cap "$DEPLOY_TASK"
else
  cd "$TARGET_APPLICATION"

  if [ -e "deploy.sh" ]; then
    echo "---> Found deploy.sh, running 'sh -e deploy.sh'" >&2
    exec sh -e deploy.sh
  else
    echo "---> No deploy.sh found, running 'bundle exec cap \"${DEPLOY_TASK}\"'" >&2
    exec bundle exec cap "$DEPLOY_TASK"
  fi
fi
