describe Requester do
  subject { described_class.new(uri).get(path, params) }

  describe '.get' do
    let(:uri) { 'http://test.test' }
    let(:path) { '/resource' }
    let(:params) { { q: 'test' } }
    let(:final_uri) do
      begin
        f_uri = URI("#{uri}#{path}")
        f_uri.query = URI.encode_www_form(params)
        f_uri
      end
    end
    let(:response) do
      double(code: 200, body: { hello: 'world' }.to_json )
    end

    context 'when is success' do
      before do
        allow(Net::HTTP).to receive(:get_response)
          .with(final_uri)
          .and_return(response)
      end

      it 'return 200' do
        expect(subject[:status]).to eq(200)
      end

      it 'returns the requested data' do
        expect(subject[:data]).to eq(JSON.parse(response.body, symbolize_names: true))
      end
    end

    context 'when it recovers from JSON::ParseError' do
      let(:response) do
        double(code: 404, body: 'Not found' )
      end

      before do
        allow(Net::HTTP).to receive(:get_response)
          .with(final_uri)
          .and_return(response)
      end

      it 'returns 404' do
        expect(subject[:status]).to eq(404)
      end

      it 'returns message error' do
        expect(subject[:data]).to eq(response.body)
      end
    end
  end
end