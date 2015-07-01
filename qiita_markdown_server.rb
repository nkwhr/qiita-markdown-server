class QiitaMarkdownServer < Sinatra::Base
  set public_folder: 'public', static: true

  before do
    headers 'Access-Control-Allow-Origin' => '*'
    unsupported_accept_header unless request.accept? 'application/json'
    validate_request_media_type!
  end

  post '/markdown' do
    text = decoded_params[:text] || missing_attribute
    process_markdown(text, options)
  end

  post '/markdown/raw' do
    text = encoded_body
    process_markdown(text)
  end

  private

  def validate_request_media_type!
    expected =
      case request.path_info
      when '/markdown'
        ['application/json']
      when '/markdown/raw'
        ['text/plain', 'text/x-markdown']
      else
        return
      end

    expected.include?(request.media_type) || \
      invalid_media_type_not(expected.join(' or '))
  end

  def raw_body
    request.body.read
  end

  def encoded_body
    raw_body.force_encoding('utf-8')
  end

  def decoded_params
    @decoded_params ||= begin
                          JSON.parse(raw_body, symbolize_names: true)
                        rescue
                          json_parse_failed
                        end
  end

  def options
    decoded_params[:options] || {}
  end

  def process_markdown(text = nil, options = {})
    result = begin
               QMKDN.call(text, options)
             rescue
               process_failed
             end
    result[:output].to_s
  end

  def process_failed
    message = { message: "Processing failed. Probably invalid format in 'options'" }
    render_error(message, 400)
  end

  def json_parse_failed
    message = { message: 'Problems parsing JSON' }
    render_error(message, 400)
  end

  def endpoint_not_found
    message = { message: 'Not Found' }
    render_error(message, 404)
  end

  def invalid_media_type_not(expected)
    message = { message: "Invalid request media type (expecting '#{expected}')" }
    render_error(message, 415)
  end

  def unsupported_accept_header
    accepted = request.accept.map { |t| "\"#{t}\"" }.join(', ')
    message = { message: "Unsupported 'Accept' header: [#{accepted}]. Must accept 'application/json'." }
    render_error(message, 415)
  end

  def missing_attribute
    message = { message: "Missing or invalid 'text' attribute in JSON request" }
    render_error(message, 422)
  end

  def render_error(message, code)
    content_type :json
    halt code, JSON.pretty_generate(message) + "\n"
  end

  not_found do
    endpoint_not_found
  end
end
