module Weather
  class API < Grape::API
    format :json

    namespace :weather do
      params do
        requires :unit, type: Symbol, values: [:celsius, :fahrenheit]
        requires :locations, type: Set[Integer], coerce_with: -> (loc) do
          raise Grape::Types::InvalidValue.new if loc.match?(/[a-bA-B]/)

          loc.include?(',') ? Set.new(loc.split(',').map(&:to_i)) : Set.new([loc.to_i])
        end
      end

      get :summary do
        fetch_summary = FetchSummary.call(unit: params[:unit], locations: params[:locations].to_a)

        return fetch_summary.results unless fetch_summary.failure?

        error!({ message: fetch_summary.results }, fetch_summary.status)
      end

      namespace :locations do
        params do
          requires :location_id, type: Integer
        end

        get '/:location_id' do
          fetch_weather = FetchWeather.call(location_id: params[:location_id])

          return fetch_weather.result unless fetch_weather.failure?

          error!({ message: fetch_weather.result }, fetch_weather.status)
        end
      end
    end
  end
end