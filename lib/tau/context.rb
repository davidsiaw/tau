# frozen_string_literal: true

module Tau
  # A stupidly simple context manager.
  # Just stores messages and returns them all. No trimming, no summarization.
  class Context
    def initialize(system_prompt: nil)
      @messages = []
      @messages << { role: :system, content: system_prompt } if system_prompt
    end

    # Helper to quickly add user/assistant messages
    def user(content)
      add_message(role: :user, content: content)
    end

    def assistant(content)
      add_message(role: :assistant, content: content)
    end

    # Return the full list of messages to send to the API
    def messages
      @messages.dup
    end

    private

    # Add a message to the history (used by public helper methods)
    def add_message(role:, content:)
      @messages << { role: role, content: content }
    end
  end
end
