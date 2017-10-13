# Deploy docker applications into Docker Swarm
#
set :ssh_options,    { :forward_agent => true, :keys => "#{ENV['HOME']}/.ssh/id_rsa" }
set :use_sudo,       false
set :user,           "deploy"
set :dockerhub_repo, "govuk"
set :branch,         ENV["TAG"] ? ENV["TAG"] : "master"
set :repo_name,      fetch(:repo_name, application).to_s
set :app_port,       fetch(:app_port)
set :replicas,       ENV['REPLICAS'] ? ENV['REPLICAS'] : '3'
set :cluster_mode,   ENV['MODE'] ? ENV['MODE'] : 'replicated'

load 'set_servers'
load 'notify'

namespace :swarm do
  # These tasks are specific to a docker swarm deployment
  desc "Deploy the application as a docker image"
  task :default do
    update
  end

  desc "Create the docker service if it has never been created"
  task :create do
    run "sudo docker service create --detach=true --name #{application} --publish #{app_port}:#{app_port} --replicas #{replicas} --mode #{cluster_mode} --env-file /etc/govuk/env.d/global.env --env-file /etc/govuk/#{application}/env.d/#{application}.env #{dockerhub_repo}/#{application}:#{branch}"
  end

  desc "Update the image if the service is already running"
  task :update do
    run "sudo docker service update #{application} --image #{dockerhub_repo}/#{application}:#{branch}"
  end

  desc "Scale replicas"
  task :scale do
    run "sudo docker service scale #{application}=#{replicas}"
  end

  desc "Restart the docker service for the application"
  task :force_reload do
    run "sudo docker service update --force #{application}"
  end

  desc "Delete the service"
  task :delete do
    run "sudo docker service rm #{application}"
  end

  desc "Recreate the service"
  task :recreate do
    delete
    create
  end
end

before "swarm", "deploy:notify:slack_message_start"
after "swarm", "deploy:notify:slack_message_done"
