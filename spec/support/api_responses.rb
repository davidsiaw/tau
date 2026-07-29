# frozen_string_literal: true

module ApiResponses
  # Fictional response body for tests. Shape matches an OpenAI-compatible
  # /v1/chat/completions response (including reasoning_content from a
  # reasoning model).
  TEXT_RESPONSE_BODY = {
    'id' => 'chatcmpl-test01',
    'object' => 'chat.completion',
    'created' => 1_000_000,
    'model' => 'test-model',
    'system_fingerprint' => 'test-fp',
    'choices' => [
      {
        'index' => 0,
        'finish_reason' => 'stop',
        'message' => {
          'role' => 'assistant',
          'content' => "\n\nHello! How can I assist you today?",
          'reasoning_content' => <<~REASONING
            \nOkay, the user said "Say hello." I need to respond appropriately. Let me start by acknowledging their greeting. A simple "Hello!" should be good. Then, I should offer assistance. Maybe ask how I can help them today. Keep it friendly and open-ended. Let me make sure the tone is welcoming and not too formal. Alright, that should cover it.\n
          REASONING
        }
      }
    ],
    'usage' => {
      'prompt_tokens' => 10,
      'completion_tokens' => 12,
      'total_tokens' => 22,
      'prompt_tokens_details' => {
        'cached_tokens' => 8
      }
    },
    'timings' => {
      'cache_n' => 8,
      'prompt_n' => 2,
      'prompt_ms' => 1.0,
      'prompt_per_token_ms' => 0.5,
      'prompt_per_second' => 2000.0,
      'predicted_n' => 12,
      'predicted_ms' => 6.0,
      'predicted_per_token_ms' => 0.5,
      'predicted_per_second' => 2000.0
    }
  }.freeze
end
