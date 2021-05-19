require "spec_helper"
require "slack_announcer"

RSpec.describe SlackAnnouncer do
  before do
    # block requests to external services
    allow(HTTP).to receive(:get).and_raise(StandardError)
    allow(HTTP).to receive(:post).and_raise(StandardError)

    ENV["TAG"] = "release_123"
    ENV["BUILD_USER"] = "Joe Bloggs"
    ENV["BUILD_NUMBER"] = "4567"
  end

  after do
    ENV.delete("TAG")
    ENV.delete("BUILD_USER")
    ENV.delete("BUILD_NUMBER")
  end

  %w[staging production].each do |environment_name|
    it "annouces a #{environment_name} deploy to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq("http://slack.url")
        expect(JSON.parse(params[:body])).to include(
          "username" => "Badger",
          "text" => ":govuk-#{environment_name}: :white_check_mark: Version " \
            "<https://release.publishing.service.gov.uk/applications/application/deploy?tag=release_123|release_123> " \
            "of <https://github.com/alphagov/application|Application> " \
            "deployed to *#{environment_name}* by Joe Bloggs",
          "channel" => "#govuk-deploy",
        )
      end

      announcer = described_class.new(environment_name, "http://slack.url")
      announcer.announce_done("application", "Application")
    end
  end

  it "does not announce deploys to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce_done("application", "Application")
  end

  it "logs and swallows announcement errors so that the deployment does not fail" do
    expect(HTTP).to receive(:post).and_raise(StandardError)

    announcer = described_class.new("production", "http://slack.url")
    expect(announcer).to receive(:puts).with(/StandardError/)
    expect { announcer.announce_done("application", "Application") }.not_to raise_error
  end

  it "can override the Slack channel" do
    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "channel" => "#some_other_channel",
      )
    end

    announcer = described_class.new("production", "http://slack.url")
    announcer.announce_done("application", "Application", "#some_other_channel")
  end

  %w[staging production].each do |environment_name|
    it "annouces a #{environment_name} deployment starting to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq("http://slack.url")
        expect(JSON.parse(params[:body])).to include(
          "username" => "Badger",
          "text" => ":govuk-#{environment_name}: :mega: Version " \
            "<https://release.publishing.service.gov.uk/applications/application/deploy?tag=release_123|release_123> " \
            "of <https://github.com/alphagov/application|Application> is being deployed to *#{environment_name}* by Joe Bloggs",
          "channel" => "#govuk-deploy",
        )
      end

      announcer = described_class.new(environment_name, "http://slack.url")
      announcer.announce_start("application", "Application")
    end
  end

  it "does not announce deploys starting to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce_start("application", "Application")
  end

  %w[staging production].each do |environment_name|
    it "announces failed deploys" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq("http://slack.url")
        expect(JSON.parse(params[:body])).to include(
          "username" => "Badger",
          "text" => ":govuk-#{environment_name}: :red_circle: Version <https://deploy.blue.#{environment_name}.govuk.digital/job/Deploy_App/4567|release_123> " \
          "of <https://github.com/alphagov/application|Application> failed to deploy to *#{environment_name}* by Joe Bloggs",
          "channel" => "#govuk-deploy",
        )
      end

      announcer = described_class.new(environment_name, "http://slack.url")
      announcer.announce_failed("application", "Application")
    end
  end

  it "does not announce failed deploys to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce_failed("application", "Application")
  end
end
