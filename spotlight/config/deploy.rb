set :application, "spotlight"
set :server_class, "performance_frontend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)
set :special_route_file, File.dirname(__FILE__) + "/spotlight_special_route.json"

load "defaults"
load "nodejs"
load "publish_special_routes_non_rails"

set :config_files_to_upload, {
  "to_upload/#{ENV['ORGANISATION']}/config.production.json.erb" => "config/config.production.json"
}

namespace :deploy do
  task :grunt do
    run "cd #{release_path} && node_modules/grunt-cli/bin/grunt build:production"
  end
end

before "deploy:finalize_update", "deploy:grunt"
