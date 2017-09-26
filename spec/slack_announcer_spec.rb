require "spec_helper"
require "slack_announcer"

RSpec.describe SlackAnnouncer do
  before do
    # block requests to external services
    allow(HTTP).to receive(:get).and_raise(StandardError)
    allow(HTTP).to receive(:post).and_raise(StandardError)

    allow(HTTP).to receive(:get)
      .with(%r{grafana.(staging\.|)publishing.service.gov.uk/api/dashboards/file/deployment_.+\.json})
      .and_return(double(:response, code: 404))
    ENV['TAG'] = 'release_123'
    ENV['BUILD_USER'] = 'Joe Bloggs'
  end

  after do
    ENV.delete('TAG')
    ENV.delete('BUILD_USER')
  end

  %w(staging production).each do |environment_name|
    it "annouces a #{environment_name} deploy to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq('http://slack.url')
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

  it "includes dashboard links for production when dashboard exists" do
    expected_text = ":govuk-production: :mega: Version " \
      "<https://release.publishing.service.gov.uk/applications/existing_app/deploy?tag=release_123|release_123> " \
      "of <https://github.com/alphagov/existing_app|Existing App> is being deployed to *production* by " \
      "Joe Bloggs (<https://grafana.publishing.service.gov.uk/dashboard/file/deployment_existing_app.json|check dashboard>)"

    expect(HTTP).to receive(:get)
      .with("https://grafana.publishing.service.gov.uk/api/dashboards/file/deployment_existing_app.json")
      .and_return(double(:response, code: 200))
    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("production", "http://slack.url")
    announcer.announce_start("existing_app", "Existing App")
  end

  it "includes dashboard links for staging when dashboard exists" do
    expected_text = ":govuk-staging: :mega: Version " \
      "<https://release.publishing.service.gov.uk/applications/existing_app/deploy?tag=release_123|release_123> of " \
      "<https://github.com/alphagov/existing_app|Existing App> is being deployed to *staging* by Joe Bloggs " \
      "(<https://grafana.staging.publishing.service.gov.uk/dashboard/file/deployment_existing_app.json|check dashboard>)"

    expect(HTTP).to receive(:get)
      .with("https://grafana.staging.publishing.service.gov.uk/api/dashboards/file/deployment_existing_app.json")
      .and_return(double(:response, code: 200))
    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("staging", "http://slack.url")
    announcer.announce_start("existing_app", "Existing App")
  end

  it "includes does not include dashboard links when an error occurs connecting to grafana server" do
    expected_text = ":govuk-production: :mega: Version " \
      "<https://release.publishing.service.gov.uk/applications/existing_app/deploy?tag=release_123|release_123> of " \
      "<https://github.com/alphagov/existing_app|Existing App> is being deployed to *production* by Joe Bloggs"

    expect(HTTP).to receive(:get).and_raise(HTTP::ConnectionError)
    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("production", "http://slack.url")
    expect(announcer).to receive(:puts).with('Unable to connect to grafana server: HTTP::ConnectionError')
    announcer.announce_start("existing_app", "Existing App")
  end

  it "Will only wait for grafana until the timeout is reached before failing the request" do
    expected_text = ":govuk-production: :mega: Version " \
      "<https://release.publishing.service.gov.uk/applications/existing_app/deploy?tag=release_123|release_123> of " \
      "<https://github.com/alphagov/existing_app|Existing App> is being deployed to *production* by Joe Bloggs"

    expect(HTTP).to receive(:get) do
      sleep 10
      double(:response, code: 200)
    end

    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("production", "http://slack.url", grafana_timeout: 0.1)
    expect(announcer).to receive(:puts).with('Unable to connect to grafana server: execution expired')
    announcer.announce_start("existing_app", "Existing App")
  end

  %w(staging production).each do |environment_name|
    it "annouces a #{environment_name} deployment starting to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq('http://slack.url')
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

  it "does not announce deploys to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce_start("application", "Application")
  end
end
