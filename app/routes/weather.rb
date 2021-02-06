module Weather
  class API < Grape::API
    format :json

    namespace :weather do
      params do
        requires :unit, type: Symbol, values: [:celsius, :fahrenheit]
        requires :locations, type: String
      end

      get :summary do
        { unit: params[:unit], locations: params[:locations] }
      end

      namespace :locations do
        params do
          requires :location_id, type: Integer
        end

        get '/:location_id' do
          { test: params[:location_id] }
        end
      end
    end
  end
end