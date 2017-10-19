# GOV.UK application deployment scripts

This repository contains Capistrano deployment scripts for applications
running on GOV.UK.

## Adding a new app

See [the documentation in the manual](https://docs.publishing.service.gov.uk/manual/setting-up-new-rails-app.html).

## How deployments work

The `jenkins.sh` script in this repo is run from the
[Jenkins job](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk_jenkins/templates/jobs/deploy_app.yaml.erb)
to deploy our applications.

Deployments to all environments use the `master` branches of this repository.

## Environment variables available to deploy scripts

There are a number of environment variables set in Jenkins that can be used in
deploy scripts:

* `DEPLOY_TO` - the environment being deployed to
* `DEPLOY_TASK` - the deploy task selected in the Jenkins interface ("deploy", "deploy:setup", etc)
* `TAG` - the tag/branch entered in the Jenkins interface ("release", "release_1234", "build-1234", etc)
* `ORGANISATION` - The vCloud organisation being deployed to
* `CI_DEPLOY_JENKINS_API_KEY` - API key used to fetch build artefacts from ci.dev.publishing.service.gov.uk.
