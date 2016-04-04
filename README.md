# ClassroomAutomator

A set of automation tools for managing coding classes on platforms like GitHub.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'classroom_automator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install classroom_automator

## Dependencies

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)


**Important! ** I am still developing everything locally, so you'll have to (clone the dependency projects, and) fix the paths in [Gemfile](Gemfile), before you can get going.



## Usage

Before you can start using the tools, you will need to run `bundle update` (in the root of this project) to download all dependencies.



Example:

```sh
 $ bin/clone_handouts ASSIGNMENT LOCAL_DIR
```

 * `CONTEXT` - Context configuration, in YAML format.       
   Specifies service providers and other properties ([see example](spec/data/context.yml)).
 * `ASSIGNMENT` - Assignment configuration file, in YAML format.       
   Specifies assignment name and handouts info ([see example](spec/data/assignment.yml))
 * `LOCAL_DIR` - A local directory where the handouts will be cloned.

 > _Note:_ This command takes a `--context` option that specifies service
 > providers, access tokens and other properties.       
 > Type `bin/clone_handouts --help` for more info.

----

### Using the console

`bin/console` can load the IRB (Ruby's interactive shell) with some convenient functions pre-loaded.

Type `bin/console --help` for more details.

If `bin/console` is supplied with a context configuration file (via `--context`, or the `CLASSROOM_AUTOMATOR_CONTEXT` environment variable), the following globals are available:

 * `logger`
 * `git`
 * `hosting`
 * `ci`


Example:

Start the console:

```sh
classroom_automator $ bin/console --context spec/data/context.yml
```

Search for repos whose name starts with `test-repo` and clone them to a local directory:

```
2.2.2 :002 > hosting.search_repos('test-repo').each do |repo|
  git.clone(repo.url, "/tmp/#{repo.name}")
end
```

Search for repos whose name starts with `test-repo` and enable CI on them:

```
2.2.2 :001 > hosting.search_repos('test-repo').each { |repo| ci.enable_ci repo.name }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/classroom_automator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
