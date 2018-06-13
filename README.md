Command: gem local
==================

> **Lets you register and manage [local bundler git repos](http://bundler.io/v1.5/git.html#local) per-project.**

If you're developing a gem alongside projects that consume them, you've probably used `gem 'name', path: '~/local/path/to/gem'` in your Gemfile before.

Of course, if you accidentally commit this, you'll probably cause somebody or someserver some grief down the line. This is why [local bundler git repos](http://bundler.io/v1.5/git.html#local) exist: so that by using `gem 'name', git: 'repo', branch: 'master'`, you can program against a local gem dependency while always leaving your Gemfile in a valid state.

However, actually *using* `bundle config local.xxx` is a bit of a pain:

- you have to remember to use the `--local` flag as well every invocation, otherwise you might bork other local projects using the dependency
- you have to remember to unset the configuration if you check out a version of your Gemfile without the `gem git:, branch:` bit
- you have to remember what that configuration was and to reset it when you checkout back to your branch
- if you frequently develop against local gems, you have to do this for every gem, in every project, and remember where you are in the above workflow every time you revisit a project after a few days

`gem local` makes this a little less of a hassle.

Installation
------------

Install this rubygems extension through rubygems:

```sh
gem install gem-local
```

Usage
-----

After installing the gem, inside your project, run:

```sh
gem local install
```

This isn't strictly neccessary--it just ensures that your local `.bundle/config` and `.gemlocal` files don't get committed.

#### Adding local repos

Define your project dependencies that you have local copies of, and their locations:

```sh
gem local add my-dependency ~/code/ruby/gems/my-dependency
```

This lets `git local` know about this dependency. Note that relative paths are supported, and `~` gets expanded, which is the format `bundle config` expects.

#### Using local repos

When you want to use your local copy, run

```sh
gem local use my-dependency
```

It updates the **local** bundler config (not *global*, as bundler does by default, which many guides run with) to refer to the path you supplied it.

#### Ignoring local repos

When you want to use the standard remote version of the dependency again, run

```sh
gem local ignore my-dependency
```

This will remove it from your bundler config and update your `.gitlocal` accordingly. If you've ever seen the message:

```sh
Cannot use local override for gem-name at path/to/gem because :branch is not specified in Gemfile.
Specify a branch or use `bundle config --delete` to remove the local override
```

you've probably checked out a different version of your Gemfile without updating your bundle config. Now you can do so with `gem local off gem-name` and not completely forget how to re-configure things when you check your WIP branch back out.

#### Multiple gems at once

The `use` and `ignore` commands (and their aliases--see them in `help <cmd>`) work for multiple gems at once, as well as all registered gems if you don't specify any.

```sh
gem local status
# off: foo @ /Users/rubyist/code/oss/foo
# on:  bar @ /Users/rubyist/code/oss/bar
# on:  fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# off: metasyntactic @ /Users/rubyist/code/oss/variable

gem local ignore bar fizz
# off: foo @ /Users/rubyist/code/oss/foo
# off: bar @ /Users/rubyist/code/oss/bar
# off: fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# off: metasyntactic @ /Users/rubyist/code/oss/variable

gem local use
# on:  foo @ /Users/rubyist/code/oss/foo
# on:  bar @ /Users/rubyist/code/oss/bar
# on:  fizz @ /Users/rubyist/code/oss/fizz
# on:  buzz @ /Users/rubyist/code/oss/buzz
# on:  metasyntactic @ /Users/rubyist/code/oss/variable

gem local ignore
# off: foo @ /Users/rubyist/code/oss/foo
# off: bar @ /Users/rubyist/code/oss/bar
# off: fizz @ /Users/rubyist/code/oss/fizz
# off: buzz @ /Users/rubyist/code/oss/buzz
# off: metasyntactic @ /Users/rubyist/code/oss/variable
```

#### Rebuilding the local gem db

If manual invocations of `bundle config --local local...` cause your `.gemlocal` file to get out of sync with bundler's settings in `.bundle/config`, run

```sh
gem local rebuild
```

to update your file against bundler's version.

#### Other commands

For other commands and usage, see

```sh
gem local help
```

For full details of a command, for example `install`, run

```sh
gem local help install
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/christhekeele/gem-local.
