# frozen_string_literal: true

require 'spec_helper'
require 'tau/llm_api'

RSpec.describe Tau::LlmApi do
  describe '#initialize' do
    it 'accepts a base URL and stores it' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)

      expect(api.instance_variable_get(:@base_url)).to eq(base_url)
    end
  end

  describe '#chat' do
    it 'returns a Response object with text' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)
      model = 'test-model'
      messages = [{ role: :user, content: 'Hello' }]
      stub_request(:post, "#{base_url}/v1/chat/completions")
        .to_return(
          status: 200,
          body: JSON.generate(ApiResponses::TEXT_RESPONSE_BODY),
          headers: { 'Content-Type' => 'application/json' }
        )

      result = api.chat(messages, model: model)

      expect(result).to be_a(Tau::Response)
      expect(result.text).to be_a(String)
      expect(result.reasoning).to be_a(String)
    end

    it 'parses text responses correctly' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)
      model = 'test-model'
      messages = [{ role: :user, content: 'Hello' }]
      stub_request(:post, "#{base_url}/v1/chat/completions")
        .to_return(
          status: 200,
          body: JSON.generate(ApiResponses::TEXT_RESPONSE_BODY),
          headers: { 'Content-Type' => 'application/json' }
        )

      result = api.chat(messages, model: model)

      expect(result.text).to eq(ApiResponses::TEXT_RESPONSE_BODY['choices'][0]['message']['content'])
      expect(result.reasoning).to eq(ApiResponses::TEXT_RESPONSE_BODY['choices'][0]['message']['reasoning_content'])
    end

    it 'exposes the raw response body for any other field' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)
      model = 'test-model'
      messages = [{ role: :user, content: 'Hello' }]
      stub_request(:post, "#{base_url}/v1/chat/completions")
        .to_return(
          status: 200,
          body: JSON.generate(ApiResponses::TEXT_RESPONSE_BODY),
          headers: { 'Content-Type' => 'application/json' }
        )

      result = api.chat(messages, model: model)

      expect(result.raw).to eq(ApiResponses::TEXT_RESPONSE_BODY)
      expect(result.raw['choices'][0]['finish_reason']).to eq('stop')
      expect(result.raw['usage']['total_tokens']).to eq(22)
      expect(result.raw['timings']['predicted_per_second']).to be_a(Float)
    end

    it 'omits max_tokens from the payload when not specified' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)
      model = 'test-model'
      messages = [{ role: :user, content: 'Hello' }]
      stub_request(:post, "#{base_url}/v1/chat/completions")
        .to_return(
          status: 200,
          body: JSON.generate(ApiResponses::TEXT_RESPONSE_BODY),
          headers: { 'Content-Type' => 'application/json' }
        )

      api.chat(messages, model: model)

      expect(a_request(:post, "#{base_url}/v1/chat/completions").with do |req|
        body = JSON.parse(req.body)
        !body.key?('max_tokens')
      end).to have_been_made
    end

    it 'includes max_tokens in the payload when specified' do
      base_url = 'http://127.0.0.1:8080'
      api = described_class.new(base_url)
      model = 'test-model'
      messages = [{ role: :user, content: 'Hello' }]
      stub_request(:post, "#{base_url}/v1/chat/completions")
        .to_return(
          status: 200,
          body: JSON.generate(ApiResponses::TEXT_RESPONSE_BODY),
          headers: { 'Content-Type' => 'application/json' }
        )

      api.chat(messages, model: model, max_tokens: 4096)

      expect(a_request(:post, "#{base_url}/v1/chat/completions").with do |req|
        body = JSON.parse(req.body)
        body['max_tokens'] == 4096
      end).to have_been_made
    end
  end

  describe 'Response' do
    it 'has text, reasoning, id, and model attributes' do
      response = Tau::Response.new(
        text: 'Hello',
        reasoning: 'I thought about it.',
        id: 'test-123',
        model: 'gpt-4'
      )

      expect(response.text).to eq('Hello')
      expect(response.reasoning).to eq('I thought about it.')
      expect(response.id).to eq('test-123')
      expect(response.model).to eq('gpt-4')
    end
  end
end
