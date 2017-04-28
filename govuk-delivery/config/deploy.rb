set :application,  "govuk-delivery"
set :server_class, "backend"
set :capfile_dir,  File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)

load "defaults"

set :repository, "#{ENV.fetch('GIT_ORIGIN_PREFIX', 'git@github.gds:gds')}/govuk_delivery.git"

load "python"

after "deploy:restart", "deploy:restart_procfile_worker"
