## Assignment

The [`Assignment`](lib/gitomator/classroom/assignment.rb) is essentially a parsed
configuration file, with a few convenience methods:

 * `repos()` - Returns an array of all repo names.
 * `permissions(repo)` - Return the permissions (name to permission) for a given repo.

Until there are proper docs, here are a few examples of valid configuration files.


#### Minimal configuration

Just a bunch of repos. `a1-repo-001` is the name of
the first repo, `a1-repo-002` is the second, `a1-repo-003` the third, and so on.

You can use this configuration and the `create-repos` task to create a bunch of empty repos.

```yaml
repos:
  - a1-repo-001
  - a1-repo-002
  - a1-repo-003
  - a1-repo-004
  # ...
```

#### Minimal configuration + `source_repo`

Allows you to `create-repos` with "starter code".        
The `master` branch of the specified `source_repo` will be pushed to each repo that is created.

 > tip: You can run the `create-repos` task with the `--update-existing` flag
 > in order to push recent changes from the `source_repo` to existing repos
 > (assuming there are no Git conflicts).

```yaml
source_repo: assignment-01-starter-code
repos:
  - a1-repo-001
  - a1-repo-002
  - a1-repo-003
  - a1-repo-004
  # ...
```


#### Specify access permissions

You can who (e.g. GitHub usernames) gets access (read-only, by default) to
each repo.

You can use this configuration file with the `update-access-permissions` script.

```yaml
repos:
  - a1-repo-001: Alice
  - a1-repo-002: Bob
  - a1-repo-003: Charlie
  - a1-repo-004: Dave
  # ...
```

You can specify multiple users per repo (e.g. for group assignments):

```yaml
repos:
  - project-01: [Alice, Bob]
  - project-02: [Charlie, Dave, Eva]
  - project-03: [Frank, George]
  # ...
```

Or, mix the two formats:

```yaml
repos:
  - project-01: [Alice, Bob]
  - project-02: Charlie
  - project-03: [Dave, Eva]
  # ...
```

#### Specify access permissions, part 2

If you want to grant users permissions other than the default one (read-only),
you can specify the permission in the config file:

```yaml
repos:
  - repo-001: Alice
  - repo-002: { Bob: write }
  - repo-003: { Charlie: admin }
  - repo-004: Dave
  # ...
```

As you might expect, you can specify multiple users per repo:

```yaml
repos:
  - repo-001: { Alice: read , Bob: write }
  - repo-002: { Charlie: admin, Dave: write }
  # ...
```

Which can also be specified as:

```yaml
repos:
  - repo-001:
     - Alice: read
     - Bob: write
  - repo-002:
     - Charlie: admin
     - Dave: write
  # ...
```


#### Specify default access permission

You specify a `default_access_permission` in the config file. For example:

```yaml
default_access_permission: write
repos:
  - repo-001: Alice
  - repo-002: Bob
  - repo-003: Charlie
  - repo-004: Dave
  # ...
```

#### Setting access permissions for teams

The names in the configuration file can refer to user and/or teams.

When using the `update-access-permissions`, you can specify the `--permission-type`
option, which can be one of the following three options:

 * `user` - The default, treat names as user names.
 * `team` - Treat names as team names.
 * `mixed` - The script will first check if a team with the given name exists. If no such team exists, treat the name as a username.
