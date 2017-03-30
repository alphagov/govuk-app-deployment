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
  task :upload_integration_initializers do
    config_folder = File.expand_path("secrets/to_upload/initializers/integration", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.rb")).each do |initializer|
        top.upload(initializer, File.join(release_path, "config/initializers/#{File.basename(initializer)}"))
      end
    end
  end
  task :upload_unicorn_config, :only => { :server_class => "frontend" } do
    config_file = File.expand_path("secrets/to_upload/unicorn.rb", Dir.pwd)
    if File.exist?(config_file)
      top.upload(config_file, File.join(release_path, "config/unicorn.rb"))
    end
  end
  task :mustache_precompile do
    run "cd #{latest_release} && #{rake} shared_mustache:compile --trace"
  end
end

if ENV['ORGANISATION'] == 'integration'
  after "deploy:upload_initializers", "deploy:upload_integration_initializers"
end
after "deploy:upload_initializers", "deploy:upload_unicorn_config"

after "deploy:symlink", "deploy:publishing_api:publish_special_routes"
after "deploy:symlink", "deploy:rummager:index"

before "deploy:assets:precompile", "deploy:mustache_precompile"
after "deploy:notify", "deploy:notify:errbit"
