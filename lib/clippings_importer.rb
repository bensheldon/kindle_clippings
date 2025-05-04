# frozen_string_literal: true

require 'yaml'

class ClippingsImporter
  def initialize(clippings_file = 'clippings.yml')
    @clippings_file = clippings_file
  end

  def merge_and_save(new_clippings)
    existing_clippings = File.exist?(@clippings_file) ? YAML.load_file(@clippings_file) : []
    all_clippings = (existing_clippings + new_clippings).each do |item|
      item['title'] = item['title'].to_s.strip
      item['author'] = item['author'].to_s.strip
      item['content'] = item['content'].to_s.strip
    end

    all_clippings.uniq! do |item|
      [item['title'], item['author'], item['type'], item['added_on'], item['location'], item['content']]
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

    all_clippings.sort_by! do |item|
      [item['added_on'] || '', item['title'] || '', item['location'] || '', item['content'] || '']
    end

    File.write(@clippings_file, all_clippings.to_yaml)
    all_clippings
  end
end
