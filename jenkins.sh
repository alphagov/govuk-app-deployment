#!/bin/bash -x

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

cd "$WORKSPACE"

logger -p INFO -t jenkins "DEPLOYMENT: ${JOB_NAME} ${BUILD_NUMBER} ${TARGET_APPLICATION} ${TAG} (${BUILD_URL})"

git clone git@github.gds:gds/alphagov-deployment.git

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

cd "$TARGET_APPLICATION"

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
