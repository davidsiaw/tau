# frozen_string_literal: true

require 'spec_helper'
require 'tau/store'
require 'tempfile'

RSpec.describe Tau::Store do
  describe '#add' do
    it 'stores a vector with metadata and returns the row id' do
      store = described_class.new(path: ':memory:', dimensions: 4)

      id = store.add(path: 'lib/a.rb', content: 'def foo; end', status: 'stable', vector: [1, 0, 0, 0])

      expect(id).to eq(1)
    end

    it 'rejects a vector with the wrong dimension' do
      store = described_class.new(path: ':memory:', dimensions: 4)

      expect do
        store.add(path: 'lib/a.rb', content: 'x', status: 'stable', vector: [1, 0, 0])
      end.to raise_error(ArgumentError, /dimension 3 does not match store dimension 4/)
    end
  end

  describe '#search' do
    it 'returns the k nearest chunks ordered by distance' do
      store = described_class.new(path: ':memory:', dimensions: 4)
      store.add(path: 'lib/a.rb', content: 'def foo; end', status: 'stable', vector: [1, 0, 0, 0])
      store.add(path: 'lib/b.rb', content: 'def bar; end', status: 'experiment', vector: [0, 1, 0, 0])
      store.add(path: 'lib/c.rb', content: 'def baz; end', status: 'stable', vector: [1, 0.1, 0, 0])

      results = store.search([1, 0, 0, 0], k_val: 2)

      expect(results.size).to eq(2)
      expect(results[0][:path]).to eq('lib/a.rb')
      expect(results[0][:distance]).to be <= results[1][:distance]
      expect(results[0][:content]).to eq('def foo; end')
      expect(results[0][:status]).to eq('stable')
    end

    it 'filters by status' do
      store = described_class.new(path: ':memory:', dimensions: 4)
      store.add(path: 'lib/a.rb', content: 'def foo; end', status: 'stable', vector: [1, 0, 0, 0])
      store.add(path: 'lib/b.rb', content: 'def bar; end', status: 'experiment', vector: [0, 1, 0, 0])
      store.add(path: 'lib/c.rb', content: 'def baz; end', status: 'stable', vector: [1, 0.1, 0, 0])

      results = store.search([0, 1, 0, 0], k_val: 3, status: 'stable')

      # Only stable chunks returned, even though the exact match is an experiment.
      expect(results.map { |r| r[:status] }).to all(eq('stable'))
      # The nearest stable chunk to [0,1,0,0] is c.rb (not the experiment b.rb).
      expect(results[0][:path]).to eq('lib/c.rb')
    end
  end

  describe '#delete_by_path' do
    it 'removes all chunks for the path from both tables' do
      store = described_class.new(path: ':memory:', dimensions: 4)
      store.add(path: 'lib/a.rb', content: 'part 1', status: 'stable', vector: [1, 0, 0, 0])
      store.add(path: 'lib/a.rb', content: 'part 2', status: 'stable', vector: [1, 0, 0, 0])
      store.add(path: 'lib/b.rb', content: 'other', status: 'stable', vector: [0, 1, 0, 0])

      store.delete_by_path('lib/a.rb')

      results = store.search([1, 0, 0, 0], k_val: 5)
      expect(results.map { |r| r[:path] }).to eq(['lib/b.rb'])
    end
  end

  describe 'persistence' do
    it 'persists across instances when using a file path' do
      Tempfile.create('tau-store') do |f|
        store1 = described_class.new(path: f.path, dimensions: 4)
        store1.add(path: 'lib/a.rb', content: 'def foo; end', status: 'stable', vector: [1, 0, 0, 0])

        store2 = described_class.new(path: f.path, dimensions: 4)
        results = store2.search([1, 0, 0, 0], k_val: 1)
        expect(results[0][:path]).to eq('lib/a.rb')
      end
    end
  end
end
