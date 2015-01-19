require 'spec_helper'

describe 'Markdown Resources' do
  describe 'POST /markdown' do
    let(:params) do
      { text: 'foobar あいうえお' }
    end

    let(:env) do
      { 'CONTENT_TYPE' => 'application/json' }
    end

    subject { post '/markdown', params.to_json, env }

    context 'with valid request media type' do
      it { should be_ok }
      it { expect(subject.status).to eq(200) }
      it { expect(subject.body).to eq("<p>foobar あいうえお</p>\n") }
    end

    context 'with invalid request media type' do
      before do
        env['CONTENT_TYPE'] = 'text/plain'
      end

      it { should_not be_ok }
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(JSON.parse(subject.body)).to eq(
          'message' => "Invalid request media type (expecting 'application/json')"
        )
      end
    end

    context 'without `text` attribute' do
      before do
        params.delete(:text)
      end

      it { should_not be_ok }
      it { expect(subject.status).to eq(422) }
      it 'should return an error message' do
        expect(JSON.parse(subject.body)).to eq(
          'message' => "Missing or invalid 'text' attribute in JSON request"
        )
      end
    end

    context 'with invalid post parameter' do
      subject { post '/markdown', params, env }

      it { should_not be_ok }
      it { expect(subject.status).to eq(400) }
      it 'should return an error message' do
        expect(JSON.parse(subject.body)).to eq('message' => 'Problems parsing JSON')
      end
    end

    context 'with options' do
      before do
        params[:text] = "Hi I'm @_nao8"
        params.merge!(options: { base_url: 'https://twitter.com' })
      end

      it { should be_ok }
      it { expect(subject.status).to eq(200) }
      it { expect(subject.body).to eq("<p>Hi I'm <a href=\"https://twitter.com/_nao8\" class=\"user-mention\" title=\"_nao8\">@_nao8</a></p>\n") }
    end

    context 'with invalid option format' do
      before do
        params.merge!(options: [base_url: 'https://twitter.com'])
      end

      it { should_not be_ok }
      it { expect(subject.status).to eq(400) }
      it 'should return an error message' do
        expect(JSON.parse(subject.body)).to eq(
          'message' => "Processing failed. Probably invalid format in 'options'"
        )
      end
    end
  end

  describe 'POST /markdown/raw' do
    let(:params) do
      'foobar あいうえお'
    end

    let(:env) do
      { 'CONTENT_TYPE' => 'text/plain' }
    end

    subject { post '/markdown/raw', params, env }

    context 'with valid request media type' do
      it { should be_ok }
      it { expect(subject.status).to eq(200) }
      it { expect(subject.body).to eq("<p>foobar あいうえお</p>\n") }
    end

    context 'with valid request media type (text/x-markdown)' do
      before do
        env['CONTENT_TYPE'] = 'text/x-markdown'
      end

      it { should be_ok }
      it { expect(subject.status).to eq(200) }
      it { expect(subject.body).to eq("<p>foobar あいうえお</p>\n") }
    end

    context 'with invalid request media type' do
      before do
        env['CONTENT_TYPE'] = 'application/json'
      end

      it { should_not be_ok }
      it { expect(subject.status).to eq(415) }
      it 'should return an error message' do
        expect(JSON.parse(subject.body)).to eq(
          'message' => "Invalid request media type (expecting 'text/plain')"
        )
      end
    end
  end

  describe 'POST /not_found' do
    subject { post '/not_found' }

    it { should_not be_ok }
    it { expect(subject.status).to eq(404) }
    it 'should return an error message' do
      expect(JSON.parse(subject.body)).to eq('message' => 'Not Found')
    end
  end
end
