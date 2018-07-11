# GOV.UK application deployment scripts

Capistrano deployment scripts for applications running on GOV.UK.

## Adding a new app

Create a new directory for your app based on one of the other apps e.g.

```
# Capfile

load 'deploy'

$:.unshift(File.expand_path('../../lib', __FILE__))
load_paths << File.expand_path('../../recipes', __FILE__)

load 'config/deploy'
```

```
# config/deploy.rb

set :application, "myapp"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "myserverclass"
set :repository, "git@github.com/alphagov/myapp.git"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :copy_exclude, [
  '.git/*'
]

after "deploy:restart"
```

## How deployments work

The master `jenkins.sh` script is run by
[Jenkins](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk_jenkins/templates/jobs/deploy_app.yaml.erb)
to deploy each app.

## Environment variables available to deploy scripts

There are a number of environment variables set in Jenkins that can be used in
deploy scripts:

* `DEPLOY_TO` - the environment being deployed to
* `DEPLOY_TASK` - the deploy task selected in the Jenkins interface ("deploy", "deploy:setup", etc)
* `TAG` - the tag/branch entered in the Jenkins interface ("release", "release_1234", "build-1234", etc)
* `ORGANISATION` - The vCloud organisation being deployed to
* `CI_DEPLOY_JENKINS_API_KEY` - API key used to fetch build artefacts from ci.dev.publishing.service.gov.uk.
