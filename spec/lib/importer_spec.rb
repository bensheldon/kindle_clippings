# frozen_string_literal: true

require 'spec_helper'
require 'importer'
require 'fileutils'

RSpec.describe Importer do
  subject(:importer) { described_class.new }

  around do |example|
    # Move the real files into the tmp directory
    FileUtils.mv('clippings.yml', 'tmp/clippings.yml')
    Dir.glob('imports/*.yml') { |file| FileUtils.mv(file, "tmp/imports/#{File.basename(file)}") }

    example.run

    # Delete any newly created test files
    Dir.glob('import_here/test_clippings*.txt') { |file| File.delete(file) }
    Dir.glob('imports/test_clippings*.yml') { |file| File.delete(file) }
    # Move the real files back into their proper place
    FileUtils.mv('tmp/clippings.yml', 'clippings.yml')
    Dir.glob('tmp/imports/*.yml') { |file| FileUtils.mv(file, "imports/#{File.basename(file)}") }
  end

  describe '#dedupe' do
    before do
      FileUtils.cp('spec/fixtures/test_clippings.txt', 'import_here/test_clippings1.txt')
      FileUtils.cp('spec/fixtures/test_clippings.txt', 'import_here/test_clippings2.txt')
      FileUtils.cp('spec/fixtures/test_clippings.txt', 'import_here/test_clippings2.txt')

      importer.import
    end

    it 'removes duplicate clippings of fragments' do
      importer.dedupe
      clippings = YAML.load_file('clippings.yml')
      expect(clippings.size).to eq 6
      expect(clippings.last['content']).to eq 'This is a fragment of the entire sentence that looks like this.'
    end
  end

  describe '#import' do
    before do
      FileUtils.cp_r('spec/fixtures/test_clippings.txt', 'import_here')
    end

    it 'creates a new yaml file' do
      importer.import

      expect(Dir['imports/test_clippings*.yml'].count).to eq 1

      # Open and parse the file with yaml
      data = YAML.load_file(Dir['imports/test_clippings*.yml'].first)
      expect(data.first).to include(
        'title' => 'The Tipping Point: How Little Things Can Make a Big Difference',
        'author' => 'Malcolm Gladwell',
        'type' => 'Highlight'
      )
    end

    it 'deletes the import txt file' do
      importer.import
      expect(Dir.glob('imports/*.txt').count).to eq 0
    end
  end
end
