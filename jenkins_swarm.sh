#!/bin/bash -x

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

cd "$WORKSPACE"

logger -p INFO -t jenkins "DEPLOYMENT: ${JOB_NAME} ${BUILD_NUMBER} ${TARGET_APPLICATION} ${TAG} (${BUILD_URL})"

cd "swarm_${TARGET_APPLICATION}"
echo "---> Deploying application into Swarm cluster"
exec bundle exec cap "$DEPLOY_TASK"
