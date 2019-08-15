require 'fetch_build'

set :application, "licensify-feed"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "licensing_backend"

# Use the build number from the release tag if given
# Otherwise, this will fall back to using the lastSuccessfulBuild below.
if ENV["TAG"] =~ /\Arelease_(\d+)\z/
  set :artefact_number, $1
end

load 'defaults'

set :deploy_to, "/data/vhost/#{application}"
set :repository, "git@github.com:alphagov/licensify"
set :custom_git_tag, "#{application}-deployed-to-#{ENV['ORGANISATION']}"

namespace :deploy do
  # This overrides the default update_code task
  desc "Copies the CI build artefact to the remote servers."
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    run "mkdir -p #{release_path}"

    # Write a file on the remote with the release info
    put "#{ENV['TAG']}\n", "#{release_path}/build_number"
    put "#{ENV['TAG']}\n", "#{release_path}/REVISION"

    bucket = ENV['S3_ARTEFACT_BUCKET']
    key = "#{application}/#{ENV['TAG']}/#{application}"

    file = fetch_from_s3_to_tempfile(bucket, key)
    logger.info "Fetching s3://#{bucket}/#{key}"

    top.upload file, "#{release_path}/#{application}.zip", :mode => "0755"
    run "cd #{release_path} && unzip #{application}.zip && mv feed-*/* . && rm #{application}.zip"
    run "chmod +x #{release_path}/bin/feed"

    procfile_content = <<-PROCFILE
    web: ./bin/frontend -Dhttp.port=\\$PORT \
    -Dpidfile.path=/dev/null \
    -J-Xms2048M -J-Xmx2048M -J-XX:+UseParallelGC -J-XX:ParallelGCThreads=4 -J-XX:+UseParallelOldGC \
    -J-Xloggc:/var/log/#{application}/gc.log -J-XX:+PrintGCDateStamps -J-XX:+PrintGCDetails \
    -Dsession.secure=true \
    -Dlogger.resource=#{application}-logger.xml \
    -Dconfig.file=/etc/licensing/gds-#{application}-config.conf \
    -Dgds.application.name=#{application} \
    -Dgds.config.file=/etc/licensing/gds-licensing-config.properties \
    -Dlicensing.beta-payments=false \
    -Djavax.net.ssl.trustStore=/etc/licensing/cacerts_java8
    PROCFILE

    run "echo \"#{procfile_content}\" > #{release_path}/Procfile"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    # The deploy user always has permission to run initctl commands.
    run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application}"
  end
end

after "deploy:notify", "deploy:notify:copy_artefact", "deploy:notify:git_clone_and_tag", "deploy:notify:docker"
