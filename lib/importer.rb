require 'kindleclippings'
require 'yaml'

class Importer
  def dedupe
    clippings = Dir.glob('imports/*.yml').each_with_object([]) do |filename, memo|
      memo.concat YAML.load_file(filename)
    end

    clippings.uniq! do |item|
      [item['title'], item['author'], item['type'], item['added_on'], item['location'], item['content']]
    end

    # Remove clippings that are fragments of other clippings
    clippings = clippings.map do |item|
      is_fragment = clippings.any? do |other|
        other != item &&
          other['type'] == 'Highlight' &&
          other['title'] == item['title'] &&
          other['type'] == item['type'] &&
          other['content'].include?(item['content'])
      end

      item unless is_fragment
    end.compact

    File.write("clippings.yml", clippings.to_yaml)
  end

  def import
    Dir.glob('import_here/*.txt').each do |filename|
      parser = KindleClippings::Parser.new
      clippings = parser.parse_file(filename)

      data = clippings.map do |clipping|
        {
          "title" => clipping.book_title,
          "author" => clipping.author,
          "type" => clipping.type.to_s,
          "added_on" => clipping.added_on.iso8601,
          "page" => clipping.page,
          "location" => clipping.location,
          "content" => clipping.content,
        }
      end

      File.write("imports/#{File.basename(filename, '.txt')}-#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.yml", data.to_yaml)
      File.delete(filename)
    end
  end
end
