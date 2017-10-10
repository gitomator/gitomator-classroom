

[![Build Status](https://travis-ci.org/gitomator/gitomator-classroom.svg?branch=master)](https://travis-ci.org/gitomator/gitomator-classroom)


 > **IMPORTANT:** `gitomator-classroom` is an example of how one would use the [`gitomator`](https://gitomator.github.io) library to run auto-marked assignments.      
 > The scripts in this repo are in pre-alpha stage, which means that (1) you will run them from source (2) you might need to "look under the hood" more than you would like to.



## Setting up


Clone this repo, and install dependencies:

```sh
git clone git@github.com:gitomator/gitomator-classroom.git
cd gitomator-classroom
bundle install
```

Add a `tagging` section to your [`.gitomator`](http://gitomator.github.io/docs/quick-start/#configure-credentials) file.
The `tagging` section will look very similar to the `hosting` section:

```yaml
tagging:
  provider: github
  access_token: YOUR-GITHUB-ACCESS-TOKEN
  organization: YOUR-GITHUB-ORGANIZATION
```

 > In Gitomator, tagging is a general concept - Items (with a primary key) in a namespace can be tagged/labeled (essentially, that's the idea of hash-tags).
 > In our case, items are pull-requests, the namespace is (the full name of) a repo, and tags are GitHub labels.


## Collecting Assignments

After the deadline of an assignment, you can run (from the root of this repo)

```
bundle exec bin/gitomator-collect-assignment YOUR-ASSIGNMENT-CONFIG
```

This script will:

 1. Disable CI on all repos
 2. Merge all pull-requests (the merged PR's will be labeled as `solution`)
 
If, for some reason, the script crashes in the middle, just re-run it - The script uses the `solution` tag as an indicator that a repo has been collected already, and skips it.

## Auto-marking

Now that the pull-requests have been merged, you need to clone all of the student repos to your machine:

```
gitomator-clone-repo YOUR-ASSIGNMENT-CONFIG SOME-LOCAL-FOLDER
```

Next, you'll need to update your assignment configuration:

```yaml
# (Required) Path to an auto-marking script that will run in the container
# For example, you can use the path (on your local machine) to bin/maven-auto-mark/run.sh
automarker_script: PATH_TO_SOME_EXECUTABLE_SHELL_SCRIPT

# (Optional) Default image is maven:3-jdk-8
docker_image : NAME_OF_DOCKER_IMAGE_TO_USE

# (Optional) By default, use the source_repo (that is already defined in this yaml file)
auto_marker_source_repo: NAME_OF_AUTO_MARKER_REPO

# (Optional) Define environment variables
env:
  ASSIGNMENT_DEADLINE: "2017-01-20 21:00"

# (Optional) Mount additional resources from the local machine to the container
# In the example below, the local folder `~/bar` will be mounted to the container as `/root/resources/foo`
resources:
  foo : ~/bar
```

And then run:

```
bundle exec bin/maven-auto-mark/a1 YOUR-ASSIGNMENT-CONFIG SOME-LOCAL-FOLDER
```

 > `bin/maven-auto-mark/a1` is an example of a script that (1) runs the auto-marker, and (2) processes the results (JUnit output) to compute a mark and generate a Markdown report.       
 > The more general purpose script, `bin/gitomator-auto-mark` only does the first part (i.e. run the auto-marker).
 
## Publishing the auto-marker results

After running the auto-marker and checking that everything looks okay, you can push the results to the students' repos by running

```
bundle exec bin/gitomator-publish-auto-marker-results
```

This script will add, commit and push all the files that were created by the auto-marker to a new branch (called `auto-marker`, by default).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
