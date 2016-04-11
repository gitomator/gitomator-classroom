# Classroom Automator

A set of automation tools for instructors in software engineering classes.

 * Manage your classes using industry-standard tools and services like GitHub and Travis CI.
    * Create teams
    * Create repositories (empty or based on an existing repo)
    * Manage access permissions (_who_ gets _which_ permission to _what_ repo)
    * And more
 * Run automation tasks using [command-line scripts](bin/task).       
    * Tasks are configured using [simple](spec/data/assignment.yml) [YAML](spec/data/teams.yml) [files](spec/data/context.yml).
    * Easy to re-run tasks with different data (e.g. test before releasing code to students, handle late submissions, etc.)
 * Perform automation tasks from an interactive console ([`bin/console`](bin/console)), without creating any Ruby scripts or classes.


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

In order to manage your Git repos, the Classroom Automator library needs a few details. For example: Your GitHub organization and access credentials.

The simplest way to get started is using the following two steps:


#### Step 1 - Create a context configuration file

Here is a minimal configuration to get you started with GitHub.

```yaml
hosting:
  provider: github
  access_token: YOUR-PERSONAL-GITHUB-ACCESS-TOKEN
  organization: YOUR-GITHUB-ORGANIZATION
```

#### Step 2 - Set it as the default configuration

Set the `CLASSROOM_AUTOMATOR_CONTEXT` environment variable to point to your context configuration file.


## Setup Teams

Create teams and team membership, based on a configuration file.

Usage:

```sh
 $ bin/task/setup_teams PATH-TO-CONFIG-FILE
```

Example config file:

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


 > _Note:_ This command will update team members' roles, but will not delete teams or remove memberships.


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