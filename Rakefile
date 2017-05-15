require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Send a test deploy message to #bot-testing to see what it looks like"
task :test_slack do
  require_relative "./lib/slack_announcer"

  ENV['TAG'] = 'test_tag_123'
  repo_name = "test_repo"
  application = "the_application"

  announcer = SlackAnnouncer.new("staging", ENV.fetch("SLACK_WEBHOOK_URL"))
  announcer.announce_start(repo_name, application, '#bot-testing')
  announcer.announce_done(repo_name, application, '#bot-testing')

  announcer = SlackAnnouncer.new("production", ENV.fetch("SLACK_WEBHOOK_URL"))
  announcer.announce_start(repo_name, application, '#bot-testing')
  announcer.announce_done(repo_name, application, '#bot-testing')
end
