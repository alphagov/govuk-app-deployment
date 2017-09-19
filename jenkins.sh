#!/bin/bash -x

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

cd "$WORKSPACE"

logger -p INFO -t jenkins "DEPLOYMENT: ${JOB_NAME} ${BUILD_NUMBER} ${TARGET_APPLICATION} ${TAG} (${BUILD_URL})"

git clone --depth 1 git@github.com:alphagov/alphagov-deployment.git

# If the application doesn't exist in this repo, fall back to
# alphagov-deployment. FIXME: Remove this when apps have migrated
# to this repo for deployment.
if [ ! -d "$TARGET_APPLICATION" ]; then
  cd "alphagov-deployment/$TARGET_APPLICATION"
  if [ -e "deploy.sh" ]; then
    echo "---> Found deploy.sh, running 'sh -e deploy.sh'" >&2
    exec env BUNDLE_GEMFILE="$WORKSPACE/Gemfile" sh -e deploy.sh
  else
    echo "---> No deploy.sh found, running 'bundle exec cap \"${DEPLOY_TASK}\"'" >&2
    exec env BUNDLE_GEMFILE="$WORKSPACE/Gemfile" bundle exec cap "$DEPLOY_TASK"
  fi
  exit 0
fi
# End FIXME

if [ $(echo $DEPLOY_TASK | grep docker) ] ; then
  cd "docker_${TARGET_APPLICATION}"
  echo "---> Deploying docker application"
  exec bundle exec cap "$DEPLOY_TASK"
else
  cd "$TARGET_APPLICATION"
  if [ -d "../alphagov-deployment/${TARGET_APPLICATION}" ]; then
    cp -r ../alphagov-deployment/$TARGET_APPLICATION secrets
  fi

  if [ -e "deploy.sh" ]; then
    echo "---> Found deploy.sh, running 'sh -e deploy.sh'" >&2
    exec sh -e deploy.sh
  else
    echo "---> No deploy.sh found, running 'bundle exec cap \"${DEPLOY_TASK}\"'" >&2
    exec bundle exec cap "$DEPLOY_TASK"
  fi
fi
