module Weather
  class API < Grape::API
    format :json
    prefix :weather

    get :summary do
    end

    get :locations do
    end
  end
end