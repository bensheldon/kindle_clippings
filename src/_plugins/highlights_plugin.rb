# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module HighlightsPlugin
  class PageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      site.data['clippings'].each do |item|
        item['added_on'] = Date.parse(item['added_on'])
      end

      # Ensure the collections exist
      site.collections['highlights'] ||= Jekyll::Collection.new(site, 'highlights')
      site.collections['books'] ||= Jekyll::Collection.new(site, 'books')
      site.collections['authors'] ||= Jekyll::Collection.new(site, 'authors')

      site.data['clippings']
          .select { |clipping| clipping['type'] == 'Highlight' }
          .group_by { |clipping| clipping['author'] }
          .each do |author_name, author_clippings|
        author_name = 'blank' if author_name.nil? || author_name == ''
        author_slug = Jekyll::Utils.slugify(author_name, mode: 'latin')
        Jekyll::PageWithoutAFile.new(site, site.source, "highlights/#{author_slug}", 'index.html').tap do |author_page|
          site.collections['authors'].docs << author_page

          author_page.data.merge!(
            'title' => author_name,
            'author_name' => author_name,
            'added_on' => author_clippings.map { |c| c['added_on'] }.max,
            'layout' => 'author'
          )

          author_page.data['books'] = author_clippings.group_by { |clipping| clipping['title'] }.map do |book_title, book_clippings|
            book_title = 'blank' if book_title.nil? || book_title == ''
            book_slug = Jekyll::Utils.slugify(book_title, mode: 'latin')
            Jekyll::PageWithoutAFile.new(site, site.source, "highlights/#{author_slug}/#{book_slug}", 'index.html').tap do |book_page|
              site.collections['books'].docs << book_page

              book_page.data.merge!(
                'title' => book_title,
                'book_title' => book_title,
                'author_name' => author_name,
                'added_on' => book_clippings.map { |c| c['added_on'] }.max,
                'author_page' => author_page,
                'layout' => 'book'
              )

              book_page.data['highlights'] = book_clippings.map do |clipping|
                highlight_slug = Jekyll::Utils.slugify([clipping['page'], clipping['location'], clipping['content'][0, 20]].join('-'), mode: 'latin')
                Jekyll::PageWithoutAFile.new(site, site.source, "highlights/#{author_slug}/#{book_slug}", "#{highlight_slug}.html").tap do |highlight_page|
                  site.collections['highlights'].docs << highlight_page

                  highlight_page.content = clipping['content']
                  highlight_page.data.merge!(
                    'title' => '',
                    'book_title' => clipping['title'],
                    'author_name' => clipping['author'],
                    'added_on' => clipping['added_on'],
                    'page' => clipping['page'],
                    'location' => clipping['location'],
                    'content' => clipping['content'],
                    'layout' => 'highlight',
                    'author_page' => author_page,
                    'book_page' => book_page
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
