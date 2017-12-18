set :application, "frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_frontend frontend)

set :source_db_config_file, false
set :db_config_file, false

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'frontend'
set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

namespace :deploy do
  task :mustache_precompile do
    run "cd #{latest_release} && #{rake} shared_mustache:compile --trace"
  end
end

after "deploy:symlink", "deploy:publishing_api:publish_special_routes"

before "deploy:assets:precompile", "deploy:mustache_precompile"
