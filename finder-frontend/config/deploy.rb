set :application, "finder-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "calculators_frontend"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'finder-frontend'
set :rails_env, 'production'
set :source_db_config_file, false
set :db_config_file, false

namespace :deploy do
  task :cold do
    puts "There's no cold task for this project, just deploy normally"
  end
  task :mustache_precompile do
    run "cd #{latest_release} && #{rake} shared_mustache:compile --trace"
  end
end

after "deploy:notify", "deploy:notify:errbit"

before "deploy:assets:precompile", "deploy:mustache_precompile"
