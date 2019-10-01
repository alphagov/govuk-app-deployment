# Deploy docker applications
#
set :ssh_options,    { :forward_agent => true, :keys => "#{ENV['HOME']}/.ssh/id_rsa", :verify_host_key => :never }
set :use_sudo,       false
set :user,           "deploy"
set :dockerhub_repo, "govuk"
set :branch,         ENV["TAG"] || "master"
set :repo_name,      fetch(:repo_name, application).to_s

load 'set_servers'
load 'notify'

namespace :docker do
  # These tasks are specific to a docker deployment
  desc "Deploy the application as a docker image"
  task :default do
    pull
    tag_to_current
    restart
  end

  desc "Pull the docker image using a specific tag"
  task :pull do
    run "sudo docker image pull #{dockerhub_repo}/#{application}:#{branch}"
  end

  desc "Tag the image to use the 'current' tag"
  task :tag_to_current do
    run "sudo docker image tag #{dockerhub_repo}/#{application}:#{branch} #{dockerhub_repo}/#{application}:current"
  end

  desc "Restart the docker service for the application"
  task :restart do
    run "sudo /etc/init.d/docker-#{application} restart"
  end
end

before "docker", "deploy:notify:slack_message_start"
after "docker", "deploy:notify:slack_message_done"
