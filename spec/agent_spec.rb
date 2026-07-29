# frozen_string_literal: true

require 'spec_helper'
require 'tau'

RSpec.describe Tau::Agent do
  describe '#prompt!' do
    it 'returns the Response and makes it available via last_response' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [Tau::Response.new(text: 'First answer', raw: {})])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      response = agent.prompt!('Hello')

      expect(response).to be_a(Tau::Response)
      expect(response.text).to eq('First answer')
      expect(agent.last_response).to eq(response)
    end

    it 'does not add the response to the context until accept!' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [Tau::Response.new(text: 'First answer', raw: {})])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      agent.prompt!('Hello')

      # Only the user message is in context, not the assistant response
      expect(context.messages).to eq([{ role: :user, content: 'Hello' }])
    end

    it 'forwards max_tokens to the llm_api' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [Tau::Response.new(text: 'First answer', raw: {})])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      agent.prompt!('Hello', max_tokens: 4096)

      expect(fake_llm_api.calls[0][:max_tokens]).to eq(4096)
    end

    it 'calling prompt! again discards the previous held response (implicit rejection)' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [
                                           Tau::Response.new(text: 'First answer', raw: {}),
                                           Tau::Response.new(text: 'Second answer', raw: {})
                                         ])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      agent.prompt!('Q1')
      first = agent.last_response

      agent.prompt!('Q2')
      second = agent.last_response

      expect(agent.last_response).to eq(second)
      expect(agent.last_response).not_to eq(first)
      expect(second.text).to eq('Second answer')
    end
  end

  describe '#accept!' do
    it 'commits the held response into the context' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [Tau::Response.new(text: 'First answer', raw: {})])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      agent.prompt!('Hello')
      expect(context.messages).to eq([{ role: :user, content: 'Hello' }])

      agent.accept!

      expect(context.messages).to eq([
                                       { role: :user, content: 'Hello' },
                                       { role: :assistant, content: 'First answer' }
                                     ])
    end

    it 'clears the held response' do
      fake_llm_api = Object.new
      fake_llm_api.instance_variable_set(:@responses, [Tau::Response.new(text: 'First answer', raw: {})])
      fake_llm_api.instance_variable_set(:@calls, [])
      def fake_llm_api.chat(messages, max_tokens: nil)
        @calls << { messages: messages, max_tokens: max_tokens }
        @responses.shift
      end
      fake_llm_api.define_singleton_method(:calls) { @calls }
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      agent.prompt!('Hello')
      agent.accept!

      expect(agent.last_response).to be_nil
    end

    it 'is a no-op when there is no held response' do
      fake_llm_api = Object.new
      def fake_llm_api.chat(*); end
      context = Tau::Context.new
      agent = described_class.new(context: context, llm_api: fake_llm_api)

      expect { agent.accept! }.not_to raise_error
      expect(context.messages).to be_empty
    end
  end
end
