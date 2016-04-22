set :application,  "email-campaign-api"
set :server_class, "email_campaign_api"
set :capfile_dir,  File.expand_path("../", File.dirname(__FILE__))

load "defaults"
load "ruby"

set :repository, "git@github.gds:email-campaign/email-campaign-api.git"

before "deploy:finalize_update", "deploy:create_mongoid_indexes"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
