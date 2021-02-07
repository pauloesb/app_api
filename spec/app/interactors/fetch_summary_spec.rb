describe FetchSummary do
  def generate_weather_data(status, unit)
    double(status: status, result: weather_data(unit))
  end

  def generate_weather_error_data(status)
    double(status: status, result: error_data(status))
  end

  def weather_data(unit)
    {
      city: Faker::Lorem.word,
      temperature: Faker::Number.number(digits: 2),
      unit: unit
    }
  end

  def error_data(status)
    {
      cod: status,
      message: Faker::Lorem.word
    }
  end
  
  subject { described_class.call(params) }

  describe '.call' do
    context 'when is success' do
      let(:unit) { :celsius }
      let(:status) { 200 }
      let(:params) do
        {
          locations: [1,2],
          unit: unit
        }
      end
      let(:weather_1) { generate_weather_data(status, unit) }
      let(:weather_2) { generate_weather_data(status, unit) }
      let(:response) { [weather_1.result, weather_2.result] }

      before do
        allow(FetchWeather).to receive(:call)
          .with(location_id: 1, unit: unit)
          .and_return(weather_1)
        allow(FetchWeather).to receive(:call)
          .with(location_id: 2, unit: unit)
          .and_return(weather_2)
      end

      it 'expected to have status nil' do 
        expect(subject.status).to be_nil
      end

      it 'expected to have context success' do
        expect(subject.success?).to be_truthy
      end

      it 'expected to have weather results' do
        expect(subject.results).to match_array(response)
      end
    end

    context 'when is failure' do
      let(:unit) { :celsius }
      let(:status) { 404 }
      let(:params) do
        {
          locations: [1,2],
          unit: unit
        }
      end
      let(:weather_1) { generate_weather_error_data(status) }
      let(:weather_2) { generate_weather_error_data(status) }
      let(:response) { [weather_1.result, weather_2.result] }
      before do
        allow(FetchWeather).to receive(:call)
          .with(location_id: 1, unit: unit)
          .and_return(weather_1)
        allow(FetchWeather).to receive(:call)
          .with(location_id: 2, unit: unit)
          .and_return(weather_2)
      end

      it 'expected to have status 404' do 
        expect(subject.status).to eq(status)
      end

      it 'expected to have context failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'expected to have error messages' do
        expect(subject.results).to match_array(response)
      end
    end
  end
end