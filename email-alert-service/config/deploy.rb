set :application, "email-alert-service"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "email_alert_api"
set :perform_hard_restart, true

load "defaults"
load "ruby"

set :copy_exclude, [
  ".git/*",
]

namespace :deploy do
  namespace :email_alert_service do
    desc "Restart the unpublishing queue consumer"
    task :restart_unpublishing_queue_consumer do
      run "sudo initctl restart email-alert-service-unpublishing-queue-consumer-procfile-worker || "\
          "sudo initctl start email-alert-service-unpublishing-queue-consumer-procfile-worker"
    end

    desc "Restart the update subscriber list details minor consumer"
    task :restart_subscriber_list_details_update_minor_consumer do
      run "sudo initctl restart email-alert-service-subscriber-list-details-update-minor-consumer-procfile-worker || "\
          "sudo initctl start email-alert-service-subscriber-list-details-update-minor-consumer-procfile-worker"
    end

    desc "Restart the update subscriber list details major consumer"
    task :restart_subscriber_list_details_update_major_consumer do
      run "sudo initctl restart email-alert-service-subscriber-list-details-update-major-consumer-procfile-worker || "\
          "sudo initctl start email-alert-service-subscriber-list-details-update-major-consumer-procfile-worker"
    end
  end
end

after "deploy:restart", "deploy:email_alert_service:restart_unpublishing_queue_consumer"
after "deploy:restart", "deploy:email_alert_service:restart_subscriber_list_details_update_major_consumer"
after "deploy:restart", "deploy:email_alert_service:restart_subscriber_list_details_update_minor_consumer"
