#!/bin/sh
set -eu
exec bundle exec cap "$DEPLOY_TASK"
