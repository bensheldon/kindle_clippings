require 'active_support/core_ext/string/inflections'

module Books
  class BooksPageGenerator < Jekyll::Generator
    safe true

    def generate(site)

      site.data['clippings'].each do |item|
        item['added_on'] = Date.parse(item['added_on'])
      end.sort_by! { |item| item['added_on'] }

      generate_books(site)
      generate_authors(site)
    end

    private

    def generate_books(site)
      site.collections['books'] ||= Jekyll::Collection.new(site, "books")

      site.data['clippings']
          .select { |item| item['type'] == 'Highlight' }
          .group_by { |item| item['title'] }
          .sort_by { |_title, clippings| clippings.map { |c| c['added_on'] }.max }
          .each do |title, clippings|
        dir = '.'
        name = Jekyll::Utils.slugify(title, mode: "latin") + '.html'

        site.collections['books'].docs << Jekyll::PageWithoutAFile.new(site, site.source, dir, name).tap do |page|
          page.content = ""
          page.data.merge!(
            "title" => title,
            "author" => clippings.first['author'],
            "added_on" => clippings.map { |c| c['added_on'] }.max,
            "clippings" => clippings,
            "permalink" => "/books/#{name}",
            "layout" => "book",
          )
        end
      end
    end

    def generate_authors(site)
      site.collections['authors'] ||= Jekyll::Collection.new(site, "authors")

      site.collections['books'].docs
          .group_by { |item| item['author'].strip }
          .sort_by { |_title, books| books.map { |b| b.data['added_on'] }.max }
          .each do |author, books|

        author = "blank" if author.blank?

        dir = '.'
        name = Jekyll::Utils.slugify(author, mode: "latin") + '.html'

        site.collections['authors'].docs << Jekyll::PageWithoutAFile.new(site, site.source, dir, name).tap do |page|
          page.content = ""
          page.data.merge!(
            "full_name" => author,
            "name" => author,
            "added_on" => books.map { |b| b.data['added_on'] }.max,
            "books" => books,
            "permalink" => "/authors/#{name}",
            "layout" => "author",
          )
        end
      end
    end
  end
end
