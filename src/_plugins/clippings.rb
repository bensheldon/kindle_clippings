# require 'active_support/core_ext/string/inflections'
#
# module Clippings
#   class ClippingPageGenerator < Jekyll::Generator
#     safe true
#
#     def generate(site)
#       site.data['clippings'].each do |clipping|
#         site.pages << ClippingPage.new(site, clipping)
#       end
#     end
#   end
#
#   # Subclass of `Jekyll::Page` with custom method definitions.
#   class ClippingPage < Jekyll::Page
#     def initialize(site, clipping)
#       @site = site                # the current site instance.
#       @base = site.source         # path to the source directory.
#       @dir  = clipping['title'].parameterize   # the directory the page will reside in.
#
#       # All pages have the same filename, so define attributes straight away.
#       @basename = 'index'      # filename without the extension.
#       @ext      = '.html'      # the extension.
#       @name     = 'index.html' # basically @basename + @ext.
#
#       # Initialize data hash with a key pointing to all posts under current category.
#       # This allows accessing the list in a template via `page.linked_docs`.
#       @data = clipping
#
#       # Look up front matter defaults scoped to type `books`, if given key
#       # doesn't exist in the `data` hash.
#       data.default_proc = proc do |_, key|
#         site.frontmatter_defaults.find(relative_path, :clippings, key)
#       end
#     end
#
#     # Placeholders that are used in constructing page URL.
#     def url_placeholders
#       {
#         :category   => @dir,
#         :basename   => basename,
#         :output_ext => output_ext,
#       }
#     end
#   end
# end
