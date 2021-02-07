class FetchWeather
  include Interactor

  WEATHER_PATH = '/weather'

  before do
    context.unit ||= :fahrenheit
  end
  
  def call
    fetch_weather_location

    context.fail! unless is_success?
  end

  private

  def requester
    @requester ||= OpenWeatherMapRequester.new
  end

  def query_data
    { id: context.location_id }.merge(temperature_units.fetch(context.unit))
  end

  def is_success?
    context.status == 200
  end

  def temperature_units
    {
      celsius: { units: 'metric' },
      fahrenheit: { units: 'imperial' }
    }
  end

  def fetch_weather_location
    response = requester.get(WEATHER_PATH, query_data)

    context.status = fetch_status(response)
    context.result = fetch_response_data(response[:data])
  end

  def fetch_status(response)
    response.fetch(:status, 500)
  end

  def fetch_response_data(data)
    {
      city: data.fetch(:name),
      temperature: data[:main].fetch(:temp),
      unit: context.unit
    }
  rescue KeyError
    data
  end
end