class FetchSummary
  include Interactor

  before do
    context.statuses = []
    context.results = []
  end

  def call
    context.locations.each(&process_location)
    
    context.fail! if context.status = context.statuses.find { |result| result != 200 } 
  end

  private

  def fetch_weather(location_id, unit)
    FetchWeather.call(location_id: location_id, unit: unit)
  end

  def process_location
    lambda do |location_id|
      res = fetch_weather(location_id, context.unit)
      context.statuses << res.status
      context.results << res.result
    end
  end
end