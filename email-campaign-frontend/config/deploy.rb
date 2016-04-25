set :application,  "email-campaign-frontend"
set :server_class, [
  "draft_email_campaign_frontend",
  "email_campaign_frontend"
]
set :capfile_dir,  File.expand_path("../", File.dirname(__FILE__))

load "defaults"
load "ruby"
load "deploy/assets"

set :repository, "git@github.gds:email-campaign/email-campaign-frontend.git"

set :assets_prefix, 'email-campaign-frontend'

after "deploy:notify", "deploy:notify:errbit"
