# Kindle Clippings Importer

Converts kindle text files into a combined, deduped/defragmented YAML file.

- Download the `My Clippings.txt` file from your Kindle into the `import_here` directory
- Run `bin/import`, which will create a new yaml file inside of `imports/` and append to `clippings.yml`

Install it: 

```ruby
bundle install
```

Tests run with:

```ruby
bundle exec rspec
bundle exec rubocop
```
