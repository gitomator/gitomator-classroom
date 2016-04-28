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

You might want to checkout our [quick start guide](https://gitomator.github.io/docs/quick-start/).

## Contributing

[Gitomator](https://github.com/gitomator) is built by software educators,
for software educators. It is

 * Extensible - You can create additional services (e.g. `cloud`) and providers (e.g. `aws`, `azure`).
 * Pluggable - You can swap between service-providers by changing a configuration file.
 * Open-source and contributor-friendly.

We are currently all at a very early, pre-alpha stage. In other words, any help will be appreciated:

 * Please give the tools a try, and provide us with some feedback.
 * Submit pull-requests
 * Open issues (bug reports, feature requests, suggestions, etc.)
 * Edit [docs](https://gitomator.github.io/docs/welcome/)
 * Spread the word and tell others about Gitomator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
