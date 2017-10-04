require 'fetch_build'

set :application, "router"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(cache draft_cache)

# Use the build number from the release tag if given
# Otherwise, this will fall back to using the lastSuccessfulBuild below.
if ENV["TAG"] =~ /\Arelease_(\d+)\z/
  set :artefact_number, $1
end

load 'defaults'

namespace :deploy do
  # This overrides the default update_code task
  desc "Copies the CI build artefact to the remote servers."
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    run "mkdir -p #{release_path}"


    if ENV['USE_S3']
      # Write a file on the remote with the release info
      put "#{ENV['TAG']}\n", "#{release_path}/build_number"
      artefact_url = "https://#{ENV['S3_ARTEFACT_BUCKET']}.s3.amazonaws.com/#{application}/#{ENV['TAG']}/#{application}"
    else
      ci_base_url = "https://ci_alphagov:#{ENV['CI_DEPLOY_JENKINS_API_KEY']}@ci.integration.publishing.service.gov.uk/job/#{application}/job/master"
      filename = application.to_s

      artefact_to_deploy = fetch(:artefact_number, fetch_last_build_number(ci_base_url))
      # Write a file on the remote with the release info
      put "#{artefact_to_deploy}\n", "#{release_path}/build_number"
      artefact_url = "#{ci_base_url}/#{artefact_to_deploy}/artifact/#{filename}"
    end

    logger.info "Fetching #{artefact_url}"
    file = fetch_to_tempfile(artefact_url)
    top.upload file, "#{release_path}/#{application}", :mode => "0755"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    # The deploy user always has permission to run initctl commands.
    run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application}"
  end
end

after "deploy:notify", "deploy:notify:github"
