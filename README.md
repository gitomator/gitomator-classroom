# Classroom Automator

A set of automation tools for software engineering classes, built on top of the Gitomator library.

 * Manage your classes using industry-standard tools and services (e.g. Git, GitHub and Travis CI).
 * Use [existing command-line scripts](bin/task) to run automation tasks.       
    * Create teams.
    * Create repositories (empty or based on an existing repo), and push updates to them.
    * Manage access permissions - _Who_ gets _which_ permission to _what_ repo?
    * Enable/disable CI
    * Merge pull-requests (i.e. collect students' solutions)
 * Configure tasks using [simple](spec/data/assignment.yml) [YAML](spec/data/teams.yml) [files](spec/data/context.yml).
    * Easy to re-run tasks with different data.
    * Easy to test run, before releasing code to students.
    * Easy to handle late submissions and other special cases.
 * Extend the library with your own [custom tasks](lib/classroom_automator/task) and command-line utilities.
 * Use an interactive console ([`bin/console`](bin/console)) to quickly perform automation tasks, without creating any command-line utilities or Ruby classes.


## Dependencies

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)

To get started, install the dependencies, clone this repo to your local machine, and run `bin/setup`
(which will install all remaining dependencies).

 > **Important:** Some of the dependencies are currently being downloaded from
 > private Git repos on BitBucket. You will need to make sure you have access
 > to these repos.


## Quick Start

The Classroom Automator library tries to take care of as many details as possible, 
but you still need to provide it with some configuration information. 
For example: Your GitHub organization name and access token, your Travis CI access token, etc.


#### Step 1 - Create a context configuration file

Here is an example of a simple configuration that will allow you to get started with GitHub and Travis CI.

```yaml
hosting:
  provider: github
  access_token: YOUR-PERSONAL-GITHUB-ACCESS-TOKEN
  organization: YOUR-GITHUB-ORGANIZATION

ci:
  provider: travis_pro
  access_token: YOUR-TRAVIS-CI-TOKEN
  github_organization: YOUR-GITHUB-ORGANIZATION
```

#### Step 2 - Set it as the default configuration

Set the `CLASSROOM_AUTOMATOR_CONTEXT` environment variable to point to your context configuration file.


### Setup Teams

Usage:

```sh
 $ bin/task/setup_teams PATH-TO-CONFIG-FILE
```

Config files can be used to declare teams and team-memberships.       
The format is YAML, and they look like this:

```yaml
Students:
  - Alice
  - Bob
  - Charlie
  - David
  - Eva

Teaching-Assistants:
  - Frank
  - George


Project-team-1:
 - Alice
 - David
 - Bob
 - { George: admin }  # We can specify a role

Project-team-2:
  - Charlie
  - Eva
  - { Frank: admin }

# ...
```

The `bin/task/setup_teams` will read the configuration file, create any missing team and team membership, and update existing members' roles.

 > _Note:_ This command will not delete teams or remove team memberships.



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
2.2.2 :002 > hosting.search_repos('test-repo').each { |repo| git.clone(repo.url, "/tmp/#{repo.name}") }
```

Search for repos whose name starts with `test-repo` and enable CI on them:

```
2.2.2 :001 > hosting.search_repos('test-repo').each { |repo| ci.enable_ci repo.name }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gitomator/classroom_automator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).