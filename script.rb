require_relative 'lib/importer'

importer = Importer.new
importer.import
importer.dedupe
