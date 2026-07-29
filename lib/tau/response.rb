# frozen_string_literal: true

module Tau
  # Represents the raw response from the LLM API.
  # Exposes the most useful fields directly, plus the full raw body via #raw
  # for anything else the server returns (usage, timings, finish_reason, etc.).
  class Response
    attr_reader :text, :reasoning, :id, :model, :raw

    def initialize(text:, reasoning: nil, id: nil, model: nil, raw: nil)
      @text = text
      @reasoning = reasoning
      @id = id
      @model = model
      @raw = raw
    end

    def to_h
      {
        text: @text,
        reasoning: @reasoning,
        id: @id,
        model: @model,
        raw: @raw
      }
    end

    def ==(other)
      other.is_a?(Response) &&
        text == other.text &&
        reasoning == other.reasoning &&
        id == other.id &&
        model == other.model &&
        raw == other.raw
    end
  end
end
