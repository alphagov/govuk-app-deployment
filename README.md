# GOV.UK application deployment scripts

This repository contains Capistrano deployment scripts for applications
running on GOV.UK.

## Adding a new app

See [the documentation on the GDS wiki](https://github.com/alphagov/wiki/wiki/Setting-up-a-new-app).

# Making changes available for Staging and Production deploys

Integration deploys use the latest master for deployments.

Staging and Production deploys use the latest on the release branch.

There is a CI job [alphagov-deployment_promote_master_to_release](https://ci.dev.publishing.service.gov.uk/job/alphagov-deployment_promote_master_to_release/) to "promote" the change to the release branch.


# Environment variables available to deploy scripts

There are a number of environment variables set in Jenkins that can be used in deploy scripts:

* `DEPLOY_TO` - the environment being deployed to
* `DEPLOY_TASK` - the deploy task selected in the Jenkins interface ("deploy", "deploy:setup", etc)
* `TAG` - the tag/branch entered in the Jenkins interface ("release", "release_1234", "build-1234", etc)
* `ORGANISATION` - The vCloud organisation being deployed to
* `CI_DEPLOY_JENKINS_API_KEY` - API key used to fetch build artefacts from ci.dev.publishing.service.gov.uk.
