# frozen_string_literal: true

require 'sqlite3'
require 'sqlite_vec'

module Tau
  # A persistent vector store backed by SQLite + the sqlite-vec extension.
  #
  # Stores L2-normalized float vectors alongside metadata (path, content,
  # status), joined on rowid. Searches via KNN then metadata filter.
  class Store
    def initialize(path:, dimensions:)
      @db = SQLite3::Database.new(path)
      @db.enable_load_extension(true)
      SqliteVec.load(@db)
      @dimensions = dimensions
      setup_schema
    end

    # Add a chunk: vector + metadata. Returns the new row id.
    def add(path:, content:, status:, vector:)
      validate_dimension(vector)
      @db.execute('INSERT INTO chunks (path, content, status) VALUES (?, ?, ?)', [path, content, status])
      id = @db.last_insert_row_id
      @db.execute('INSERT INTO vec_items (rowid, embedding) VALUES (?, ?)', [id, pack_vector(vector)])
      id
    end

    # Search for the k nearest chunks to +vector+, optionally filtered.
    # Returns an array of { path:, content:, status:, distance: } hashes.
    def search(vector, k_val:, status: nil)
      validate_dimension(vector)
      params = [pack_vector(vector), k_val]
      params << status if status
      rows = @db.execute(knn_query(status), params)
      rows.map do |path, content, status, distance|
        { path: path, content: content, status: status, distance: distance }
      end
    end

    # Delete all chunks for a given path (invalidation on overwrite).
    def delete_by_path(path)
      @db.execute('DELETE FROM vec_items WHERE rowid IN (SELECT id FROM chunks WHERE path = ?)', [path])
      @db.execute('DELETE FROM chunks WHERE path = ?', [path])
    end

    private

    def setup_schema
      @db.execute("CREATE VIRTUAL TABLE IF NOT EXISTS vec_items USING vec0(embedding float[#{@dimensions}])")
      @db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS chunks (
          id INTEGER PRIMARY KEY,
          path TEXT,
          content TEXT,
          status TEXT
        )
      SQL
      @db.execute('CREATE INDEX IF NOT EXISTS idx_chunks_path ON chunks(path)')
    end

    def knn_query(status)
      where = status ? " WHERE c.status = ?\n" : ''
      <<~SQL
        SELECT c.path, c.content, c.status, v.distance
        FROM (SELECT rowid, distance FROM vec_items WHERE embedding MATCH ? AND k = ? ORDER BY distance) v
        JOIN chunks c ON c.id = v.rowid
        #{where}ORDER BY v.distance
      SQL
    end

    def pack_vector(vector)
      SQLite3::Blob.new(vector.pack('f*'))
    end

    def validate_dimension(vector)
      return if vector.size == @dimensions

      raise ArgumentError, "vector dimension #{vector.size} does not match store dimension #{@dimensions}"
    end
  end
end
