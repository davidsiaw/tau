# frozen_string_literal: true

module Tau
  # Splits text into chunks small enough to embed, preferring blank-line
  # boundaries (which respect code structure: methods, paragraphs, blocks).
  #
  # Oversized blocks that exceed +max_size+ characters are further split on
  # single newlines into pieces that fit.
  class Chunker
    def initialize(max_size: 1500)
      @max_size = max_size
    end

    # Split +text+ into an array of chunk strings.
    def chunk(text)
      text.split(/\n\n+/).flat_map { |block| split_block(block) }
    end

    private

    def split_block(block)
      return [block] if block.length <= @max_size

      # Oversized block: split on single newlines into <= max_size pieces.
      pieces = []
      current = ''
      block.split("\n").each do |line|
        current = append_line(current, line, pieces)
      end
      pieces << current unless current.empty?
      pieces
    end

    def append_line(current, line, pieces)
      return line if current.empty?

      candidate = "#{current}\n#{line}"
      return candidate if candidate.length <= @max_size

      pieces << current
      line
    end
  end
end
