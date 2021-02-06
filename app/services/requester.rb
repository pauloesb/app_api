require 'net/http'
require 'json'

class Requester
  def initialize(uri)
    @uri = uri
  end

  def get(path, **params)
    url = prepare_url(path)

    url.query = URI.encode_www_form(**params)

    res = Net::HTTP.get_response(url)    

    JSON.parse(res.body, symbolize_names: true) if res.is_a?(Net::HTTPSuccess)
  rescue JSON::ParserError
    res.body
  end

  private

  def prepare_url(path)
    URI("#{@uri}#{path}")
  end
end

