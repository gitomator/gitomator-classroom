> **IMPORTANT:** All Gitomator projects are currently in pre-alpha stage, which means that:        
 >
 >  * Some parts are not implemented
 >  * API's may change significantly
 >  * There are not a lot of tests
 >
 > If that scares you, no problem, come back in a couple of weeks. We'll be in alpha stage soon.      
 > If you want to contribute to Gitomator (as a developer and/or user), Great! Please keep on reading.
 >


# Gitomator - Classroom

_Classroom_ is a set of automation tools for instructors in software engineering courses.           

If you

 * Teach a software engineering course,
 * Where you _distribute code_ to students in the form of _Git repos_,
 * And use (or, would like to use) services such _GitHub_ and _Travis CI_.

Then, _Classroom_ can help you automate your workflow.


_Classroom_ is

 * Extensible - You can create additional services (e.g. `cloud`) and providers (e.g. `aws`, `azure`).
 * Pluggable - You can swap between service-providers by changing a configuration file.
 * Open-source and contributor-friendly.

So, please join the conversation by opening issues and/or submitting pull-requests.

#### What does it do?

_Classroom_ can automate many common tasks, for example:

 * Creating repos and teams in your GitHub organization.
 * Managing access permissions to repos in your GitHub organization.
 * Cloning repos locally, committing and pushing updates.
 * Enabling/disabling CI.
 * And more

And includes command-line tools that implement a complete workflow:

 * Publishing coding assignments as GitHub repositories
 * Providing students with immediate feedback on their work, by enabling Travis CI.
 * Collecting assignments, by merging pull-requests.
 * Cloning, auto-marking and pushing results back to the students' repos.

_Classroom_ can be used in different ways:

 * Using the command-line tools
 * From an interactive console - Great for developing workflows and running quick maintenance tasks.
 * Or, by extending the libraries with your own custom workflow and command-line tools (requires basic Ruby programming).


----

## Dependencies

Once the the following dependencies are installed:

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (developed and tested with Ruby 2.2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)
 * [Bundler](http://bundler.io/)

Clone this repo and run `bin/setup` (which will download and install all remaining dependencies).

 > **Important:** Some dependencies are currently being pulled from [private Git repos](https://bitbucket.org/joey_freund/classroom_automator/src/a1e339070955d44dcb2d3eefe5890e15f5f83860/Gemfile?fileviewer=file-view-default). You will need to have access to these repos.

----

## _Classroom_ in 60 seconds

Create a YAML file, `tmp/context.yml`, containing your GitHub information:

```yaml
hosting:
  provider: github
  username: YOUR-GITHUB-USERNAME
  password: YOUR-GITHUB-PASSWORD
  organization: YOUR-GITHUB-ORGANIZATION
```

 > *Important:* You should never commit login credentials to version control.       

Start the interactive console:

```sh
 $ bin/console --context tmp/context.yml
```

That's it!            

#### Using the console

You can now manage your GitHub organization from the interactive console. For example:

Search for all repos in your organization:

```ruby
hosting.search_repos('')
```

Or, clone all repos from your GitHub organization to the `/tmp` folder on your local machine:

```ruby
hosting.search_repos('').each { |repo| git.clone(repo.url, "/tmp/#{repo.name}") }
```

Or, create a test repo (called `test-repo`) in your GitHub organization:

```ruby
hosting.create_repo('test-repo')
```

OK, let's stop here (you can type `exit` to exit the console).      



## Automation Tasks

The console is very useful for testing, developing workflows and/or running quick maintenance tasks.
Most users, on the other hand, will prefer to automate their workflow using the command-line tools.
Let's see a couple of examples ...


#### Setup Teams

Create teams and team membership, based on a configuration file.

Usage:

```sh
 $ bin/task/setup_teams PATH-TO-CONFIG-FILE
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
 $ bin/task/create_repos PATH-TO-CONFIG-FILE
```

Example config file:

```yaml
source_repo: assignment-starter-code

repos:
  - assignment-handout-01
  - assignment-handout-02
  - assignment-handout-03
```


#### Setup Permissions

Grant access permissions to repos.

Usage:

```sh
 $ bin/task/set-access-permissions PATH-TO-CONFIG-FILE
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