require "spec_helper"
require "docker_tag_pusher"

RSpec.describe DockerTagPusher do
  subject(:instance) { described_class.new("foo", "bar") }

  context "with token authentication" do
    before do
      allow(instance).to receive(:token).with("govuk/publishing-api") { "bazqux" }
    end

    describe "#has_repo?" do
      before do
        stub_request(
          :get,
          "https://registry-1.docker.io/v2/govuk/publishing-api/tags/list?n=1"
        ).with(headers: {
          "Authorization" => "Bearer bazqux",
        }).to_return(status: status)
      end

      context "when a repo exists" do
        let(:status) { 200 }

        it "returns true" do
          expect(instance.has_repo?("govuk/publishing-api")).to be true
        end
      end

      context "when a repo doesn't exist" do
        let(:status) { 404 }

        it "returns false" do
          expect(instance.has_repo?("govuk/publishing-api")).to be false
        end
      end

      context "when an error occurs" do
        let(:status) { 401 }

        it "raises an error" do
          expect { instance.has_repo?("govuk/publishing-api") }.to raise_error(/Error \(401\) checking repo exists/)
        end
      end
    end

    describe "#get_manifest" do
      context "when an image is found" do
        it "returns the manifest as a string" do
          json = File.read("spec/fixtures/publishing-api.json")

          stub_request(
            :get,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/master"
          ).with(headers: {
            "Authorization" => "Bearer bazqux",
            "Accept" => "application/vnd.docker.distribution.manifest.v2+json",
          }).to_return(body: json, headers: {
            "Content-Type" => "application/vnd.docker.distribution.manifest.v2+json",
          })

          expect(instance.get_manifest("govuk/publishing-api", "master")).to eq(json)
        end
      end

      context "when no image is found" do
        it "raises an error" do
          stub_request(
            :get,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/master"
          ).with(headers: {
            "Authorization" => "Bearer bazqux",
            "Accept" => "application/vnd.docker.distribution.manifest.v2+json",
          }).to_return(status: 404)

          expect { instance.get_manifest("govuk/publishing-api", "master") }.to raise_error("Image or tag not found")
        end
      end

      context "when an error occurs accessing the image" do
        it "raises an error" do
          stub_request(
            :get,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/master"
          ).with(headers: {
            "Authorization" => "Bearer bazqux",
            "Accept" => "application/vnd.docker.distribution.manifest.v2+json",
          }).to_return(status: 401)

          expect { instance.get_manifest("govuk/publishing-api", "master") }.to raise_error(/Error \(401\) while fetching manifest/)
        end
      end

      context "when the image is in the wrong format" do
        it "raises an error" do
          stub_request(
            :get,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/master"
          ).with(headers: {
            "Authorization" => "Bearer bazqux",
            "Accept" => "application/vnd.docker.distribution.manifest.v2+json",
          }).to_return(headers: {
            "Content-Type" => "application/vnd.docker.distribution.manifest.vWrong",
          })

          expect { instance.get_manifest("govuk/publishing-api", "master") }.to raise_error(/Remote image not in correct format/)
        end
      end
    end

    describe "#put_manifest" do
      context "when successful" do
        it "puts the manifest at a new tag" do
          json = File.read("spec/fixtures/publishing-api.json")

          stub_request(
            :put,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/foobar"
          ).with(
            body: json,
            headers: {
              "Authorization" => "Bearer bazqux",
              "Content-Type" => "application/vnd.docker.distribution.manifest.v2+json",
            }
          ).to_return(status: 201)

          expect(instance.put_manifest("govuk/publishing-api", json, "foobar")).to be nil
        end
      end

      context "when failed" do
        it "raises an error" do
          json = File.read("spec/fixtures/publishing-api.json")

          stub_request(
            :put,
            "https://registry-1.docker.io/v2/govuk/publishing-api/manifests/foobar"
          ).with(
            body: json,
            headers: {
              "Authorization" => "Bearer bazqux",
              "Content-Type" => "application/vnd.docker.distribution.manifest.v2+json",
            }
          ).to_return(status: 500, body: "Error")

          expect { instance.put_manifest("govuk/publishing-api", json, "foobar") }
            .to raise_error("Server error while putting manifest: Error")
        end
      end
    end
  end
end
