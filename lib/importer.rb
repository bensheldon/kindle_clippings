# frozen_string_literal: true

require_relative 'kindle_importer'
require_relative 'kobo_importer'

class Importer
  def import_kindle
    KindleImporter.new(clippings_file).import
  end

  def import_kobo
    KoboImporter.new(clippings_file).import
  end

  def clippings_file
    'clippings.yml'
  end
end
