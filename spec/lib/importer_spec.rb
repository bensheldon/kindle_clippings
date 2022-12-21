# frozen_string_literal: true

require 'spec_helper'
require 'importer'
require 'fileutils'

RSpec.describe Importer do
  subject(:importer) { described_class.new }

  around do |example|
    # Move the real files into the tmp directory
    FileUtils.mv('clippings.yml', 'tmp/clippings.yml')
    Dir.glob('import_here/*.tmp') { |file| FileUtils.mv(file, "tmp/imports/#{File.basename(file)}") }

    example.run

    # Delete any newly created test files
    Dir.glob('import_here/test_clippings*.txt') { |file| File.delete(file) }
    # Move the real files back into their proper place
    FileUtils.mv('tmp/clippings.yml', 'clippings.yml')
    Dir.glob('tmp/imports/*.txt') { |file| FileUtils.mv(file, "import_here/#{File.basename(file)}") }
  end

  describe '#import' do
    before do
      FileUtils.cp('spec/fixtures/test_clippings.yml', 'clippings.yml')

      # Import a few files to test deduping
      FileUtils.cp('spec/fixtures/test_clippings.txt', 'import_here/test_clippings1.txt')
      FileUtils.cp('spec/fixtures/test_clippings.txt', 'import_here/test_clippings2.txt')
    end

    it 'appends to the clippings.yml file' do
      initial_clippings = YAML.load_file('clippings.yml')
      expect(initial_clippings.size).to eq 1

      importer.import

      final_clippings = YAML.load_file('clippings.yml')

      expect(final_clippings.size).to eq 7
      expect(final_clippings.first).to include(
        'title' => 'Existing Clipping',
        'author' => 'Existing author',
        'type' => 'Highlight'
      )
    end

    it 'deletes the import txt file' do
      importer.import
      expect(Dir.glob('imports/*.txt').count).to eq 0
    end
  end
end
