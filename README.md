# Classroom Automator

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


## Setup

To get started, clone this repo to your local machine, and run `bin/setup`
(which will install all remaining dependencies).

 > **Important:** Some of the dependencies are currently being downloaded from
 > private Git repos on BitBucket. You will need to make sure you have access
 > to these repos.


## Usage

TODO: Write this section ...


### Using `bin/console`

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gitomator/classroom_automator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
