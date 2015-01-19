require 'spec_helper'

describe QiitaMarkdownServer do
  describe 'QMKDN' do
    it { expect(QMKDN).to be_a Qiita::Markdown::Processor }
  end
end
