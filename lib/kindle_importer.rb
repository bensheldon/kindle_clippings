# frozen_string_literal: true

require_relative 'clippings_importer'
require 'kindleclippings'
require 'yaml'

class KindleImporter < ClippingsImporter
  def initialize(clippings_file = 'clippings.yml', import_dir = 'import_here')
    super(clippings_file)
    @import_dir = import_dir
  end

  def import
    new_clippings = kindle_files.flat_map do |filename|
      content = File.read(filename, encoding: 'bom|utf-8')
      content.gsub!(/^/, '')

      parser = KindleClippings::Parser.new
      results = parser.parse(content).map do |clipping|
        {
          'title' => clipping.book_title.strip,
          'author' => clipping.author.strip,
          'type' => clipping.type.to_s,
          'added_on' => clipping.added_on.iso8601,
          'page' => clipping.page,
          'location' => clipping.location,
          'content' => clipping.content.strip
        }
      end

      File.delete(filename)
      results
    end
    merge_and_save(new_clippings)
  end

  def kindle_files
    Dir.glob(File.join(@import_dir, '*.txt'))
  end
end
