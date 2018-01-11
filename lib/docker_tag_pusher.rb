require 'json'
require 'net/http'
require 'uri'

class DockerTagPusher
  REGISTRY = 'https://registry-1.docker.io'.freeze
  MEDIA_TYPE = 'application/vnd.docker.distribution.manifest.v2+json'.freeze

  attr_reader :username, :password
  private :username, :password

  def initialize(username, password)
    @username = username
    @password = password
  end

  def get_manifest(repo, tag)
    request = Net::HTTP::Get.new(
      "#{REGISTRY}/v2/#{repo}/manifests/#{tag}",
      'Authorization' => "Bearer #{token(repo)}",
      'Accept' => MEDIA_TYPE
    )
    response = registry_client.request(request)

    raise 'Image or tag not found' if response.code == '404'
    raise "Remote image not in correct format (must be #{MEDIA_TYPE})" if response['Content-Type'] != MEDIA_TYPE
    raise "Server error while fetching manifest: #{response.body}" if response.code != '200'

    response.body
  end

  def put_manifest(repo, manifest, tag)
    request = Net::HTTP::Put.new(
      "#{REGISTRY}/v2/#{repo}/manifests/#{tag}",
      'Authorization' => "Bearer #{token(repo)}",
      'Content-Type' => MEDIA_TYPE
    )
    request.body = manifest
    response = registry_client.request(request)

    raise "Server error while putting manifest: #{response.body}" if response.code != '201'
  end

private

  def token(repo)
    uri = URI.parse("https://auth.docker.io/token?service=registry.docker.io&scope=repository:#{repo}:pull,push")

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      request.basic_auth username, password
      response = http.request request
      JSON.parse(response.body)['token']
    end
  end

  def registry_client
    @registry_client ||= begin
      uri = URI.parse(REGISTRY)
      Net::HTTP.new(uri.host, uri.port).tap do |client|
        client.use_ssl = uri.scheme == 'https'
      end
    end
  end
end
