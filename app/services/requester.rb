require 'net/http'
require 'json'

class Requester
  def initialize(uri)
    @uri = uri
  end

  def get(path, **params)
    url = prepare_url(path)

    url.query = URI.encode_www_form(**params)

    response = Net::HTTP.get_response(url)

    { status: response.code.to_i, data: parse_data(response) }
  rescue JSON::ParserError
    res.body
  end

  private

  def prepare_url(path)
    URI("#{@uri}#{path}")
  end

  def parse_data(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end

