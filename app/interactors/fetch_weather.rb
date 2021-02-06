class FetchWeather
  include Interactor

  WEATHER_PATH = '/weahter'
  
  def call
    if data = requester.get(WEATHER_PATH, query_data(context))
      context.data = data
    else
      context.fail!
    end
  end

  private

  def requester
    @requester ||= OpenWeatherMapRequester.new
  end

  def query_data(context)
    { id: context.location_id }
  end
end