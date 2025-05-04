# frozen_string_literal: true

require_relative 'clippings_importer'
require 'sqlite3'
require 'yaml'
require 'date'

class KoboImporter < ClippingsImporter
  def initialize(clippings_file = 'clippings.yml', sqlite_path = 'tmp/koboreader.sqlite')
    super(clippings_file)
    @sqlite_path = sqlite_path
  end

  def import
    db = SQLite3::Database.new(@sqlite_path)
    db.results_as_hash = true

    query = <<-SQL
      SELECT
        Bookmark.Text AS content,
        Bookmark.Annotation AS annotation,
        Bookmark.DateCreated AS added_on,
        Bookmark.ContentID AS location,
        Bookmark.Type AS type,
        book.Title AS title,
        book.Attribution AS author
      FROM Bookmark
      LEFT JOIN content AS book ON book.ContentID = Bookmark.VolumeID
      WHERE Bookmark.Text IS NOT NULL AND TRIM(Bookmark.Text) != ''
      ORDER BY Bookmark.DateCreated ASC
    SQL

    results = db.execute(query)

    clippings = results.map do |row|
      {
        'title' => (row['title'] || '').strip,
        'author' => (row['author'] || '').strip,
        'type' => 'Highlight',
        'added_on' => begin
          DateTime.parse(row['added_on']).strftime('%Y-%m-%dT%H:%M:%S')
        rescue StandardError
          row['added_on']
        end,
        'page' => nil,
        'location' => row['location'],
        'content' => (row['content'] || '').strip
      }
    end

    merge_and_save(clippings)
  end
end
