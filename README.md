# Classroom Automator

A set of automation tools for instructors in software engineering classes.

 * Manage your classes using industry-standard tools and services.
    * Publish coding assignments as GitHub repositories.
    * Provide students with (almost) immediate feedback on their work, using Travis CI.
 * Run automation tasks using [command-line scripts](bin/task).
    * Create teams
    * Create repositories (empty or based on an existing repo)
    * Manage access permissions (_who_ gets _which_ permission to _what_ repo)
    * and much more ...
 * Perform quick automation-related tasks from an interactive console.          
    * No need to write any Ruby scripts or classes.
 * Swap between service providers by changing a configuration file.         
    * For example, store student repos on your own file server, or use custom CI service.


## Quick Start

Before you can get started, you'll need to complete a few simple steps.

#### Step 0 - Install dependencies

First, install the following dependencies:

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)

Then, clone this repo to your local machine and run `bin/setup` (which will install all remaining dependencies).

 > **Important:** Some dependencies are currently being pulled from [private Git repos](https://bitbucket.org/joey_freund/classroom_automator/src/a1e339070955d44dcb2d3eefe5890e15f5f83860/Gemfile?fileviewer=file-view-default). You will need to make sure you have access to these repos.


#### Step 1 - Create a context configuration file

_Classroom automator_ needs to know a few things, before it manage your infrastructure for you.      
Here is a minimal configuration to get you started with GitHub.

```yaml
hosting:
  provider: github
  access_token: YOUR-PERSONAL-GITHUB-ACCESS-TOKEN
  organization: YOUR-GITHUB-ORGANIZATION
```

#### Step 2 - Set it as the default configuration

Set the `CLASSROOM_AUTOMATOR_CONTEXT` environment variable to point to your context configuration file.


## Automation Tasks


#### Setup Teams

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
```


 > _Note:_ This command will update team members' roles, but will not delete teams or remove memberships.


## The Interactive Console

The `bin/console` script loads the IRB (Ruby's interactive shell) with a few convenient functions/variables pre-loaded.

To be more specific, you can provide `bin/console` with a context configuration file (via `--context`, or the `CLASSROOM_AUTOMATOR_CONTEXT` environment variable). When the console loads, it will initialize a context object, based on the specified configuration file, and will make the following functions/variables available:

 * `logger`
 * `git`
 * `hosting`
 * `ci`
 * `classroom_automator_context`

Type `bin/console --help` for more details.


#### Examples

Start the console:

```sh
classroom_automator $ bin/console --context spec/data/context.yml
```

Search for repos whose name contains `test-repo`, and clone them to a local directory:

```
2.2.2 :002 > hosting.search_repos('test-repo').each { |repo| git.clone(repo.url, "/tmp/#{repo.name}") }
```

Enable CI on all repos (in the organization) whose name contains `test-repo`:

```
2.2.2 :001 > hosting.search_repos('test-repo').each { |repo| ci.enable_ci repo.name }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gitomator/classroom_automator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).