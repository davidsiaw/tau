# frozen_string_literal: true

module Tau
  # The agent orchestrates the conversation but does NOT run the loop.
  #
  # The last response is held (not committed to the context) until the client
  # accepts it. Calling prompt! again discards the previous held response.
  class Agent
    def initialize(context:, llm_api:)
      @context = context
      @llm_api = llm_api
      @last_response = nil
    end

    # The last response from the API, or nil if none.
    attr_reader :last_response

    # Prompt the agent with a user message.
    #
    # The user message and the response are held back from the context until
    # #accept! is called. Calling prompt! again discards any previously held
    # exchange (implicit rejection).
    #
    # Returns the Response.
    def prompt!(user_message = nil, max_tokens: nil)
      @context.user(user_message) if user_message
      response = @llm_api.chat(@context.messages, max_tokens: max_tokens)
      @last_response = response
      response
    end

    # Commit the last exchange (user message + response) into the context.
    # No-op if there is no held response.
    def accept!
      return unless @last_response

      @context.assistant(@last_response.text)
      @last_response = nil
    end
  end
end
