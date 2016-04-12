# Gitomator - Classroom

_Classroom_ is a set of automation tools for instructors in software engineering courses.           

#### Who should use it?

If you

 * Teach a software engineering course,
 * Where you distribute code to students in the form of Git repos,
 * And you feel like you could benefit from automating your workflow.

Then you should give _Classroom_ a try.

#### What does it do?

_Classroom_ makes it easy to automate your workflow.       

 * Publish coding assignments as GitHub repositories
 * Provide students with (almost) immediate feedback on their work, using Travis CI.
 * Manage teams and access permissions to repos in your GitHub organization.
 * And much more

There are three ways to use _Classroom_:

 * From an interactive console - Develop workflows and run quick maintenance tasks. No coding required.
 * Using the command-line tools
 * By extending _Classroom_ with your own command-line tools, using basic Ruby programming.


#### What else?

_Classroom_ is

 * Extensible - Create additional services (e.g. `cloud`) and providers (e.g. `aws`, `azure`).
 * Pluggable - Swap between providers by changing a configuration file.
 * Open-source - We're happy to accept pull-requests.


## Dependencies

Once the the following dependencies are installed:

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)

Clone this repo and run `bin/setup` (which will download and install all remaining dependencies).

 > **Important:** Some dependencies are currently being pulled from [private Git repos](https://bitbucket.org/joey_freund/classroom_automator/src/a1e339070955d44dcb2d3eefe5890e15f5f83860/Gemfile?fileviewer=file-view-default). You will need to have access to these repos.


## Quick Start

Let's see how to use _Classroom Automator_ to manage the repos in your GitHub organization.


#### Create a context configuration file

Create a YAML file, `context.yml`, that contains your GitHub information:

```yaml
hosting:
  provider: github
  username: YOUR-GITHUB-USERNAME
  password: YOUR-GITHUB-PASSWORD
  organization: YOUR-GITHUB-ORGANIZATION
```

 > **Important:** Do not commit files with password information to version control.

#### Start the console

From the root of this repo, run:

```sh
 $ bin/console --context PATH-TO-YOUR-CONTEXT-YML
```

At this point, you are running a Ruby REPL that has a few convenience methods and variables.       
Let's start by searching for all repos in your GitHub organization:

```ruby
hosting.search_repos('')
```

Or, cloning all repos in the organization to the `/tmp` folder on your local machine:

```ruby
hosting.search_repos('').each { |repo| git.clone(repo.url, "/tmp/#{repo.name}") }
```

If your organization does not have any repos, you can create one:

```ruby
hosting.create_repo('test-repo')
```

OK, let's stop here (you can type `exit` to exit the console).      



## Automation Tasks

The console is an extremely convenient tool, but usually you want to run some pre-defined (and properly tested) automation task.

Let's see some of the automation tasks that are currently available.


#### Setup Teams

Create teams and team membership, based on a configuration file.

Usage:

```sh
 $ bin/task/setup_teams PATH-TO-CONFIG-FILE
```

Example config file, with two teams and three members (specified by their GitHub usernames) each.

```yaml
Team-01:
  - Alice
  - Bob
  - Charlie

Team-02:
  - David
  - Eva
  - Frank
```

#### Create Repos

Create repos, optionally with some starter code.

Usage:

```sh
 $ bin/task/create_repos PATH-TO-CONFIG-FILE
```

Example config file:

```yaml

# Specify an existing repo (in your GitHub organization) as the starter code
source_repo: assignment-starter-code

repos:
  - assignment-handout-01
  - assignment-handout-02
  - assignment-handout-03
```


#### Setup Permissions

Grant users/teams access to repos.

Usage:

```sh
 $ bin/task/set_user_permissions PATH-TO-CONFIG-FILE
 $ bin/task/set_team_permissions PATH-TO-CONFIG-FILE
```

Example config file:

```yaml
source_repo: assignment-1-starter-code

repos:
  - assignment-handout-01: Alice
  - assignment-handout-02: Bob
  - assignment-handout-03: Charlie
```

 > _Note:_ The same config file can be used for `create-repos`, `set-user-permissions` and `set-team-permission`.


## What's next?

You should probably go and read the docs.
The only problem is ... there are no docs at the moment.
More on that below, in the [Contributing](#Contributing) section.


## Contributing

Classroom Automator [and all other Gitomator libraries](https://github.com/gitomator) are all at a very early, pre-alpha stage.
In other words, any help will be appreciated:

 * Please give the tools a try, and provide us with some feedback.
 * Bug reports and pull requests are welcome on GitHub at https://github.com/gitomator/classroom_automator.
 * Spread the word and tell others about Gitomator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).