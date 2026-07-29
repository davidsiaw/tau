# frozen_string_literal: true

require 'spec_helper'
require 'tau/embedder_api'

RSpec.describe Tau::EmbedderApi do
  describe '#embed_document' do
    it 'prepends the search_document: prefix and returns the vector' do
      base_url = 'http://127.0.0.1:8081'
      embedder = described_class.new(base_url)
      stub_request(:post, "#{base_url}/v1/embeddings")
        .with do |req|
          body = JSON.parse(req.body)
          body['input'] == 'search_document: def foo; end' &&
            body['embd_normalize'] == 2 && body['encoding_format'] == 'float'
        end
        .to_return(
          status: 200,
          body: JSON.generate({ 'data' => [{ 'index' => 0, 'embedding' => [0.1, 0.2, 0.3] }] }),
          headers: { 'Content-Type' => 'application/json' }
        )

      result = embedder.embed_document('def foo; end')

      expect(result).to eq([0.1, 0.2, 0.3])
    end
  end

  describe '#embed_query' do
    it 'prepends the search_query: prefix and returns the vector' do
      base_url = 'http://127.0.0.1:8081'
      embedder = described_class.new(base_url)
      stub_request(:post, "#{base_url}/v1/embeddings")
        .with do |req|
          body = JSON.parse(req.body)
          body['input'] == 'search_query: how do I foo' &&
            body['embd_normalize'] == 2 && body['encoding_format'] == 'float'
        end
        .to_return(
          status: 200,
          body: JSON.generate({ 'data' => [{ 'index' => 0, 'embedding' => [0.4, 0.5, 0.6] }] }),
          headers: { 'Content-Type' => 'application/json' }
        )

      result = embedder.embed_query('how do I foo')

      expect(result).to eq([0.4, 0.5, 0.6])
    end
  end

  it 'requests L2 normalization (embd_normalize: 2)' do
    base_url = 'http://127.0.0.1:8081'
    embedder = described_class.new(base_url)
    stub_request(:post, "#{base_url}/v1/embeddings")
      .to_return(
        status: 200,
        body: JSON.generate({ 'data' => [{ 'index' => 0, 'embedding' => [0.0] }] }),
        headers: { 'Content-Type' => 'application/json' }
      )

    embedder.embed_query('x')

    expect(a_request(:post, "#{base_url}/v1/embeddings").with do |req|
      JSON.parse(req.body)['embd_normalize'] == 2
    end).to have_been_made
  end

  it 'raises on a non-200 response' do
    base_url = 'http://127.0.0.1:8081'
    embedder = described_class.new(base_url)
    stub_request(:post, "#{base_url}/v1/embeddings")
      .to_return(status: 500, body: 'boom')

    expect { embedder.embed_query('x') }.to raise_error(/Embedding API Error: 500/)
  end
end
