require "spec_helper"
require "slack_announcer"

RSpec.describe SlackAnnouncer do
  %w(staging production).each do |environment_name|
    it "annouces a #{environment_name} deploy to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq('http://slack.url')
        expect(JSON.parse(params[:body])).to include(
          "username" => "Badger",
          "text" => "<https://github.com/alphagov/alphagov/whitehall|Whitehall> was just deployed to *#{environment_name}*",
          "channel" => "#2ndline",
        )
      end

      announcer = described_class.new(environment_name, "http://slack.url")
      announcer.announce("alphagov/whitehall", "Whitehall")
    end
  end

  it "does not announce deploys to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce("alphagov/whitehall", "Whitehall")
  end

  it "logs and swallows announcement errors so that the deployment does not fail" do
    expect(HTTP).to receive(:post).and_raise(StandardError)

    announcer = described_class.new("production", "http://slack.url")
    expect(announcer).to receive(:puts).with(/StandardError/)
    expect { announcer.announce("alphagov/whitehall", "Whitehall") }.not_to raise_error
  end
end
