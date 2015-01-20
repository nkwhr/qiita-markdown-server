require 'spec_helper'

describe 'Markdown Resources' do

  shared_examples 'API Response' do
    it 'should have correct headers' do
      expect(subject.header['Access-Control-Allow-Origin']).to eq('*')
      expect(subject.header['Content-Type']).to eq('text/html;charset=utf-8')
    end
    it { should be_ok }
    it { expect(subject.status).to eq(200) }
  end

  shared_examples 'API Error Response' do
    it 'should have correct headers' do
      expect(subject.header['Access-Control-Allow-Origin']).to eq('*')
      expect(subject.header['Content-Type']).to eq('application/json')
    end
    it { should_not be_ok }
  end

  let(:message) do
    JSON.parse(subject.body)['message']
  end

  describe 'POST /markdown' do
    let(:params) do
      { text: 'foobar あいうえお' }
    end

    let(:env) do
      { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => '*/*' }
    end

    subject { post '/markdown', params.to_json, env }

    context 'with Content-Type: application/json' do
      it_behaves_like 'API Response'
      it 'should respond with HTML elements' do
        expect(subject.body).to eq("<p>foobar あいうえお</p>\n")
      end
    end

    context 'with Content-Type: text/plain' do
      before do
        env['CONTENT_TYPE'] = 'text/plain'
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(message).to eq("Invalid request media type (expecting 'application/json')")
      end
    end

    context 'with Accept: text/plain' do
      before do
        env['HTTP_ACCEPT'] = 'text/plain'
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(message).to eq("Unsupported 'Accept' header: [\"text/plain\"]. Must accept 'application/json'.")
      end
    end

    context 'without `text` attribute' do
      before do
        params.delete(:text)
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(422) }
      it 'should return an error message' do
        expect(message).to eq("Missing or invalid 'text' attribute in JSON request")
      end
    end

    context 'with non-JSON parameter' do
      subject { post '/markdown', params, env }

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(400) }
      it 'should return an error message' do
        expect(message).to eq('Problems parsing JSON')
      end
    end

    context 'with options' do
      before do
        params[:text] = "Hi I'm @_nao8"
        params.merge!(options: { base_url: 'https://twitter.com' })
      end

      it_behaves_like 'API Response'
      it 'should respond with HTML elements' do
        expect(subject.body).to eq(
          "<p>Hi I'm <a href=\"https://twitter.com/_nao8\" class=\"user-mention\" title=\"_nao8\">@_nao8</a></p>\n"
        )
      end
    end

    context 'with invalid option format' do
      before do
        params.merge!(options: [base_url: 'https://twitter.com'])
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(400) }
      it 'should return an error message' do
        expect(message).to eq("Processing failed. Probably invalid format in 'options'")
      end
    end
  end

  describe 'POST /markdown/raw' do
    let(:params) do
      'foobar あいうえお'
    end

    let(:env) do
      { 'CONTENT_TYPE' => 'text/plain', 'HTTP_ACCEPT' => '*/*' }
    end

    subject { post '/markdown/raw', params, env }

    context 'with Content-Type: text/plain' do
      it_behaves_like 'API Response'
      it 'should respond with HTML elements' do
        expect(subject.body).to eq("<p>foobar あいうえお</p>\n")
      end
    end

    context 'with Content-Type: text/x-markdown' do
      before do
        env['CONTENT_TYPE'] = 'text/x-markdown'
      end

      it_behaves_like 'API Response'
      it 'should respond with HTML elements' do
        expect(subject.body).to eq("<p>foobar あいうえお</p>\n")
      end
    end

    context 'with Content-Type: application/json' do
      before do
        env['CONTENT_TYPE'] = 'application/json'
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(message).to eq("Invalid request media type (expecting 'text/plain')")
      end
    end

    context 'with Accept: text/plain' do
      before do
        env['HTTP_ACCEPT'] = 'text/plain'
      end

      it_behaves_like 'API Error Response'
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(message).to eq("Unsupported 'Accept' header: [\"text/plain\"]. Must accept 'application/json'.")
      end
    end

  end

  describe 'POST /not_found' do
    subject { post '/not_found' }

    it { should_not be_ok }
    it { expect(subject.status).to eq(404) }
    it 'should return an error message' do
      expect(message).to eq('Not Found')
    end
  end
end
