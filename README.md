> **IMPORTANT:** All Gitomator projects are currently in pre-alpha stage, which means that:        
 >
 >  * Some parts are not implemented
 >  * API's may change significantly
 >  * There are not a lot of tests
 >


# Gitomator - Classroom

[![Build Status](https://travis-ci.org/gitomator/gitomator-classroom.svg?branch=master)](https://travis-ci.org/gitomator/gitomator-classroom)

_Classroom_ is a set of automation tools for instructors in software engineering courses.           

It can automate tasks such as:

 * Creating repos and teams in your GitHub organization.
 * Managing access permissions to repos in your GitHub organization.
 * Cloning repos locally, committing and pushing updates.
 * Enabling/disabling CI.

And it includes command-line tools that implement a complete workflow:

 * Publishing coding assignments as GitHub repositories
 * Providing students with immediate feedback on their work, by enabling Travis CI.
 * Collecting assignments, by merging pull-requests.
 * Cloning, auto-marking and pushing results back to the students' repos.


So, if you

 * Teach a software engineering course,
 * Where you _distribute code_ to students in the form of _Git repos_,
 * And use (or, would like to use) services such _GitHub_ and _Travis CI_.

You might want to give _Classroom_ a try.

----

One more thing ... _Classroom_ is built by software educators, for software educators. It is

 * Extensible - You can create additional services (e.g. `cloud`) and providers (e.g. `aws`, `azure`).
 * Pluggable - You can swap between service-providers by changing a configuration file.
 * Open-source and contributor-friendly.

please join the conversation, open issues and/or submit pull-requests.


----

## Quick Start


### Install Dependencies

_Classroom_ has the following dependencies:

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)

Once they are installed, clone this repo and run `bin/setup` (which will download and install all remaining dependencies).

 > **Important:** Some dependencies are currently being pulled from [private Git repos](Gemfile). You will need to have access to these repos.


### Setup GitHub Credentials

Create a YAML file, `tmp/context.yml`, containing your GitHub information:

```yaml
hosting:
  provider: github
  username: YOUR-GITHUB-USERNAME
  password: YOUR-GITHUB-PASSWORD
  organization: YOUR-GITHUB-ORGANIZATION
```

 > *Important:* You should never commit login credentials to version control.       


### Run The Interactive Console

The command
```sh
 $ bin/console --context tmp/context.yml
```

Will start the interactive console, where you can manage your GitHub organization. Let's see a few examples:

 * Search for all repos in your organization:
```ruby
      hosting.search_repos('')
```

 * Clone all repos from your GitHub organization to the `/tmp` folder on your local machine:
```ruby
      hosting.search_repos('').each { |repo| git.clone(repo.url, "/tmp/#{repo.name}") }
```

 * Create a test repo (called `test-repo`) in your GitHub organization:
```ruby
      hosting.create_repo('test-repo')
```

OK, let's stop here (you can type `exit` to exit the console).      



## Command-line Tools

The console is very useful for testing, developing workflows and/or running quick maintenance tasks.
Most users, on the other hand, will prefer to automate their workflow using the command-line tools.
Let's see a couple of examples ...

 > _Tip:_ All of the command-line tools accept a `--help` flag.

#### Update Teams

Create/update teams and team membership, based on a configuration file.

Usage:

```sh
 $ bin/task/update-teams PATH-TO-CONFIG-FILE
```

Example config file:

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

 > _Clarification:_ In the example above, `Alice`, `Bob`, `Charlie`, `David`, `Eva` and `Frank` are GitHub usernames of students/TA's in the class.

#### Create Repos

Create repos, optionally with some starter code.

Usage:

```sh
 $ bin/task/create-repos PATH-TO-CONFIG-FILE
```

Example config file:

```yaml
source_repo: assignment-starter-code

repos:
  - assignment-handout-01
  - assignment-handout-02
  - assignment-handout-03
```


#### Update Access Permissions

Grant access permissions to repos.

Usage:

```sh
 $ bin/task/update-access-permissions PATH-TO-CONFIG-FILE
```

Example config file:

```yaml
repos:
  - assignment-handout-01: Alice
  - assignment-handout-02: Bob
  - assignment-handout-03: Charlie
```

 > _Note:_ The same config file can be used for `create-repos`, `set-access-permissions`.


## What's next?

You should probably go and read the docs.
The problem is ... there [isn't much documentation](docs) at the moment. 
Which is yet another reason why you should read the next section.


## Contributing

Classroom Automator [and all other Gitomator libraries](https://github.com/gitomator) are all at a very early, pre-alpha stage.
In other words, any help will be appreciated:

 * Please give the tools a try, and provide us with some feedback.
 * Bug reports and pull requests are welcome on GitHub at https://github.com/gitomator/gitomator-classroom.
 * Spread the word and tell others about Gitomator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
