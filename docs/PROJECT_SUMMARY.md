# Tau - Minimal Ruby Agent Framework

A lightweight, step-based agent framework for building LLM-powered coding assistants in Ruby.

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Context   │ ←→  │    Agent    │ ←→  │     API     │
│ (Messages)  │     │  (Step Logic)│     │ (LLM Client)│
└─────────────┘     └─────────────┘     └─────────────┘
```

## Core Components

### 1. `Tau::Api` - LLM Communication
- OpenAI-compatible API client
- Supports both **standard JSON tool calls** (OpenAI format) and **XML tool calls** (SmolLM3/Bonsai format)
- Automatic detection and parsing of tool calls
- Uses **REXML** for robust XML parsing

```ruby
api = Tau::Api.new('http://localhost:12345')
response = api.chat(messages, model: 'my-model')
# response.text, response.tool_calls, response.id, response.model
```

### 2. `Tau::Context` - Message History
- Simple message store (no trimming yet)
- Stores system prompt, user messages, assistant responses, and tool results

```ruby
ctx = Tau::Context.new(system_prompt: "You are helpful.")
ctx.user("Hello")
ctx.assistant("Hi there!")
ctx.messages # => Array of messages
```

### 3. `Tau::Agent` - Step Orchestrator
- **No loop** - takes one step at a time
- Returns `State` object with `:done`, `:tool_call`, or `:thinking` status
- You control the loop externally

```ruby
agent = Tau::Agent.new(context: ctx, api: api, tools: { read: ->(args) { ... } })
state = agent.next_state("Read file.rb")

case state.status
when :tool_call
  # Execute tools and feed results back
when :done
  puts state.text_response
end
```

## Installation

```bash
bundle install
```

Dependencies:
- `rexml` (~> 3.0) - XML parsing (lightweight, stdlib-compatible)

## Usage Example

```ruby
require 'bundler/setup'
require 'tau'

# Setup
api = Tau::Api.new('http://localhost:12345')
ctx = Tau::Context.new(system_prompt: "You are a helpful coding assistant.")

tools = {
  'read' => ->(args) { File.read(args['path']) }
}

agent = Tau::Agent.new(context: ctx, api: api, tools: tools)

# Conversation loop
state = agent.next_state("Read test.rb")

loop do
  case state.status
  when :tool_call
    state.tool_calls.each do |tc|
      result = agent.execute_tool(tc)
      agent.add_tool_result(tool_id: tc.id, content: result)
    end
    state = agent.next_state # Continue with results
  
  when :done
    puts state.text_response
    break
  end
end
```

## Tool Call Formats

### Standard OpenAI (JSON)
```json
{
  "tool_calls": [{
    "id": "call_123",
    "function": {
      "name": "read",
      "arguments": "{\"path\":\"file.rb\"}"
    }
  }]
}
```

### SmolLM3/Bonsai (XML)
```xml
<read><path>file.rb</path></read>
```

The `Api` class automatically detects and parses both formats!

## Design Philosophy

- **Stupidly simple first**: No trimming, no summarization, no token counting
- **Step-based**: No built-in loop - you control the flow
- **Composable**: Each component is independent and testable
- **Lightweight**: Minimal dependencies (just REXML)

## Future Enhancements

- Context window management (sliding window / summarization)
- Token counting and limits
- Streaming support
- More tool types (bash, edit, write, etc.)
- Parallel tool execution

## Testing

```bash
# Run tests
bundle exec rspec

# Run RuboCop
bundle exec rubocop

# Live API test
TEST_LIVE_API=true bundle exec rspec
```

## License

MIT
