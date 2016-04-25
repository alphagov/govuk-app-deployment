set :application,  "share-sale-publisher"
set :server_class, "backend"
set :capfile_dir,  File.expand_path('../', File.dirname(__FILE__))

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

set :repository, "git@github.gds:email-campaign/share-sale-publisher.git"

set :assets_prefix, 'share-sale-publisher'

after "deploy:notify", "deploy:notify:errbit"
