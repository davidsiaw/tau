# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Tau
  # OpenAI-compatible API client for LLM communication
  class LlmApi
    def initialize(base_url)
      @base_url = base_url
      @uri = URI.parse(base_url)
    end

    # Send a chat completion request to the LLM
    # messages: Array of {role: :user|:assistant|:system, content: String}
    # model: Model name to use (optional, omitted to let the server choose)
    # max_tokens: Maximum completion tokens (optional, omitted to use server default)
    # Returns: Response object
    def chat(messages, model: nil, max_tokens: nil)
      payload = {
        messages: format_messages(messages),
        stream: false
      }
      payload[:model] = model if model
      payload[:max_tokens] = max_tokens if max_tokens

      response_data = send_request('/v1/chat/completions', payload)
      build_response(response_data)
    end

    private

    def build_response(response_data)
      message = response_data.dig('choices', 0, 'message') || {}
      Response.new(
        text: message['content'],
        reasoning: message['reasoning_content'],
        id: response_data['id'],
        model: response_data['model'],
        raw: response_data
      )
    end

    def send_request(path, payload)
      uri = build_uri(path)
      http = build_http(uri)
      request = build_request(uri, payload)

      response = http.request(request)
      handle_response(response)
    end

    def build_uri(path)
      URI.parse("#{@base_url}#{path}")
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = @uri.scheme == 'https'
      http
    end

    def build_request(uri, payload)
      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      request
    end

    def handle_response(response)
      raise "API Error: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def format_messages(messages)
      messages.map do |msg|
        {
          role: msg[:role].to_s,
          content: msg[:content]
        }
      end
    end
  end
end
