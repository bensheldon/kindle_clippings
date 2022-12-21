# Kindle Clippings Importer and Viewer

Converts kindle text files into a combined, deduped/defragmented YAML file.

- Download the `My Clippings.txt` file from your Kindle into the `import_here` directory
- Run `bin/import`, which will append the clipping to the `clippings.yml` file in the root of the project (the initial txt file will then be removed)

Install it: 

```ruby
bundle install
```

Tests run with:

```ruby
bundle exec rspec
bundle exec rubocop
```
