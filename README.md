# Kindle Clippings Importer and Viewer

Automatically ingests Kindle's `My Clippings.txt` files; combines, dedupes, and preserves their contents (Highlights/Bookmarks/Notes), and generates a simple website for reading and exploring them.

This project uses **GitHub Actions** to automatically ingest and process the `My Clippings.txt` files, re-committing the updated [`clippings.yml`](./clippings.yml) back to this repository. Then, a custom **Jekyll** static site is generated and published to **GitHub Pages**.  

## To use entirely through GitHub.com

1. Download the `My Clippings.txt` file from your Kindle
2. Upload your `My Clippings.txt` into the [`import_here`](./import_here) directory via the GitHub UI.

## Development

Install it: 

```ruby
bundle install
```

Tests run with:

```ruby
bundle exec rspec
bundle exec rubocop
```

Manually run the import script:

```ruby
bin/import
```

Manually build/develop the website:

```ruby
bundle exec jekyll server
```
