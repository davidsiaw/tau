# frozen_string_literal: true

module Tau
  # Represents the state of an agent after taking a step.
  class AgentState
    attr_reader :status, :text_response

    def initialize(status:, text_response: nil)
      @status = status
      @text_response = text_response
    end

    def done?
      @status == :done
    end

    def to_h
      {
        status: @status,
        text_response: @text_response
      }
    end

    def ==(other)
      other.is_a?(AgentState) &&
        status == other.status &&
        text_response == other.text_response
    end
  end
end
