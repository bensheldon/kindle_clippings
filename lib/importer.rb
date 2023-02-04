# frozen_string_literal: true

require 'kindleclippings'
require 'yaml'

class Importer
  def import
    new_clippings = kindle_files.flat_map do |filename|
      content = File.read(filename, encoding: 'bom|utf-8')
      content.gsub!(/^\xEF\xBB\xBF/, '')

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

    existing_clippings = YAML.load_file(clippings_file)

    all_clippings = (existing_clippings + new_clippings).each do |item|
      item['title'] = item['title'].strip
      item['author'] = item['author'].strip
      item['content'] = item['content'].strip
    end

    all_clippings.uniq! do |item|
      [item['title'], item['author'], item['type'], item['added_on'], item['location'], item['content']]
    end

    all_clippings.each do |item|
      item['title'].strip
    end

    # Remove any clippings that are substrings of other, longer, clippings
    all_clippings = all_clippings.filter_map do |item|
      is_fragment = all_clippings.any? do |other|
        other != item &&
          other['type'] == 'Highlight' &&
          other['title'] == item['title'] &&
          other['type'] == item['type'] &&
          other['content'].include?(item['content'])
      end

      item unless is_fragment
    end

    all_clippings.sort_by! { |item| [item['added_on'], item['title'], item['location']] }
    File.write(clippings_file, all_clippings.to_yaml)

    all_clippings
  end

  def kindle_files
    Dir.glob('import_here/*.txt')
  end

  def imported_files
    Dir.glob('imports/*.yml')
  end

  def clippings_file
    'clippings.yml'
  end
end
