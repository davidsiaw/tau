# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Tau
  # Client for an OpenAI-compatible /v1/embeddings endpoint.
  # Returns L2-normalized float vectors ready for a vector store.
  #
  # Uses nomic-embed-text task prefixes by default:
  #   - embed_document: prepends "search_document:" (for indexing)
  #   - embed_query:    prepends "search_query:"    (for retrieval)
  class EmbedderApi
    def initialize(base_url)
      @base_url = base_url
    end

    # Embed text for indexing (document side). Returns Array<Float>.
    def embed_document(text)
      embed("search_document: #{text}")
    end

    # Embed text for querying (query side). Returns Array<Float>.
    def embed_query(text)
      embed("search_query: #{text}")
    end

    private

    def embed(text)
      uri = URI.parse("#{@base_url}/v1/embeddings")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(build_request(uri, text))
      end
      raise "Embedding API Error: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).dig('data', 0, 'embedding')
    end

    def build_request(uri, text)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(input: text, encoding_format: 'float', embd_normalize: 2)
      request
    end
  end
end
