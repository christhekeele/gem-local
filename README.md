Command: gem local
==================

> **Lets you register and manage [local bundler git repos](http://bundler.io/v1.5/git.html#local) per-project.**

Installation
------------

Install this rubygems extension through rubygems:

```sh
gem install gem-local
```

Usage
-----

### Initialization

If using git, inside a project with a `Gemfile` where you want to be able to toggle local bundler gem loadpaths, run:

```sh
gem local install
```

This ensures that the local `.bundle/config` and `.gemlocal` files don't get committed.

### Adding local repos

Define the dependencies of this project that you have local copies of, and their locations:

```sh
gem local add my-dependency ~/code/ruby/gems/my-dependency
```

This lets `git local` know about this dependency.

### Using local repos

When you want to use your local copy, run

```sh
gem local use my-dependency
```

It updates the **local** bundler config (not *global*, as bundler does by default, which many tutorials run with) to refer to the path you supplied it.

### Ignoring local repos

When you want to use the remote version again, run

```sh
gem local ignore my-dependency
```

This will remove it from your bundler config and update your `.gitlocal` accordingly to know it's been disabled.

### Multiple gems at once

The `use` and `ignore` commands (and their aliases--see the `help`) work for multiple registered gems at once, as well as all registered gems if you don't specify any.

```sh
gem local status
# off: foo @ /Users/rubyist/code/oss/foo
# on:  bar @ /Users/rubyist/code/oss/bar
# on:  fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# off:  metasyntactic @ /Users/rubyist/code/oss/variable

gem local ignore bar fizz
# off: foo @ /Users/rubyist/code/oss/foo
# off: bar @ /Users/rubyist/code/oss/bar
# off: fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# off:  metasyntactic @ /Users/rubyist/code/oss/variable

gem local enable
# on:  foo @ /Users/rubyist/code/oss/foo
# on:  bar @ /Users/rubyist/code/oss/bar
# on:  fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# on:  metasyntactic @ /Users/rubyist/code/oss/variable

gem local disable
# off: foo @ /Users/rubyist/code/oss/foo
# off: bar @ /Users/rubyist/code/oss/bar
# off: fizz @ /Users/rubyist/code/oss/fizz
# off: buzz @ /Users/rubyist/code/oss/buzz
# off: metasyntactic @ /Users/rubyist/code/oss/variable
```

### Rebuilding the local gem db

If invocations of `bundle config --local local...` cause your `.gemlocal` file to get out of sync with bundler's settings in `.bundle/config`, run

```sh
gem local rebuild
```

to update your file against bundler's configuration.

### Other commands

For other commands and usage, see

```sh
gem local help
```

### Detailed help

For details on a command, for example `install`, run

```sh
gem local help install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christhekeele/gem-local.
