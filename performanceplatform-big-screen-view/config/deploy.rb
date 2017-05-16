set :application, "performanceplatform-big-screen-view"
set :server_class, "performance_frontend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)
set :special_route_file, File.dirname(__FILE__) + "/performance_platform_big_screen_view_special_route.json"

load "defaults"
load "nodejs"
load "publish_special_routes_non_rails"

namespace :deploy do
  task :gulp do
    run "cd #{release_path} && node_modules/gulp/bin/gulp.js production && rm -rf node_modules"
  end

  task :restart do
    # nothing
  end
end

after "deploy:finalize_update", "deploy:gulp"
