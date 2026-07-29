# frozen_string_literal: true

require 'spec_helper'
require 'tau/chunker'

RSpec.describe Tau::Chunker do
  describe '#chunk' do
    it 'returns a single chunk for short text' do
      chunker = described_class.new(max_size: 1000)

      chunks = chunker.chunk('def foo; end')

      expect(chunks).to eq(['def foo; end'])
    end

    it 'splits on blank lines into separate chunks' do
      chunker = described_class.new(max_size: 1000)

      text = "module Auth\n  def login; end\n\n  def logout; end\nend"
      chunks = chunker.chunk(text)

      expect(chunks.size).to eq(2)
      expect(chunks[0]).to eq("module Auth\n  def login; end")
      expect(chunks[1]).to eq("  def logout; end\nend")
    end

    it 'further splits oversized blocks on single newlines' do
      chunker = described_class.new(max_size: 50)

      # A single block (no blank lines) of 3 lines, total > 50 chars.
      text = "line one is fairly long\nline two is also long\nline three is long too"
      chunks = chunker.chunk(text)

      expect(chunks.size).to be > 1
      # No chunk exceeds max_size
      chunks.each { |c| expect(c.length).to be <= 50 }
      # Reassembling the chunks (joining with newlines) reproduces the original
      expect(chunks.join("\n")).to eq(text)
    end

    it 'returns an empty array for empty text' do
      chunker = described_class.new

      expect(chunker.chunk('')).to eq([])
    end

    it 'uses the default max_size of 1500 when not specified' do
      chunker = described_class.new

      # A block of 1500 chars stays as one chunk; 1501 would split.
      text = 'x' * 1500
      expect(chunker.chunk(text)).to eq([text])

      text2 = 'x' * 1501
      # No newlines to split on, so it stays as one piece (can't be made smaller)
      expect(chunker.chunk(text2)).to eq([text2])
    end
  end
end
