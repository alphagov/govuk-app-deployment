set :application,  "govuk-delivery"
set :server_class, "backend"
set :capfile_dir,  File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)

load "defaults"

set :repository, "#{ENV.fetch('GIT_ORIGIN_PREFIX', 'git@github.gds:gds')}/govuk_delivery.git"

load "python"

namespace :deploy do
  task :upload_organisation_config do
    Dir.glob(File.join(Dir.pwd, "secrets/to_upload/#{ENV['ORGANISATION']}/*")).each do |f|
      top.upload(f, File.join(release_path, File.basename(f)))
    end
  end
end

after "deploy:finalize_update", "deploy:upload_organisation_config"
after "deploy:restart", "deploy:restart_procfile_worker"
