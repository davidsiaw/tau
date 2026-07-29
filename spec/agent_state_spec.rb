# frozen_string_literal: true

require 'spec_helper'
require 'tau/agent_state'

RSpec.describe Tau::AgentState do
  describe '#initialize' do
    it 'creates a done state' do
      state = described_class.new(status: :done, text_response: 'Hello')

      expect(state.status).to eq(:done)
      expect(state.text_response).to eq('Hello')
    end
  end

  describe '#done?' do
    it 'returns true for :done status' do
      state = described_class.new(status: :done)
      expect(state.done?).to be true
    end
  end

  describe '#to_h' do
    it 'converts to hash correctly' do
      state = described_class.new(
        status: :done,
        text_response: 'Hello'
      )

      result = state.to_h

      expect(result).to eq({
                             status: :done,
                             text_response: 'Hello'
                           })
    end
  end

  describe '#==' do
    it 'compares states correctly' do
      state1 = described_class.new(status: :done, text_response: 'Hello')
      state2 = described_class.new(status: :done, text_response: 'Hello')
      state3 = described_class.new(status: :done, text_response: 'World')

      expect(state1).to eq(state2)
      expect(state1).not_to eq(state3)
    end
  end
end
