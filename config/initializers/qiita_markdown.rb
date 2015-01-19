require 'qiita-markdown'
require 'yaml'
require 'erb'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/hash/keys'

settings = YAML.load(ERB.new(File.read('config/qiita_markdown.yml')).result)
options = if settings[ENV['RACK_ENV']].nil?
            {}
          else
            settings[ENV['RACK_ENV']].deep_symbolize_keys.compact
          end

QMKDN = Qiita::Markdown::Processor.new(options)
