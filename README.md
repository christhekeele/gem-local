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

Inside a project with a `Gemfile` where you want to be able to toggle local bundler gem loadpaths, run:

```sh
gem local install
```

Define the dependencies of this project that you have local copies of, and their locations:

```sh
gem local add my-dependency ~/code/ruby/gems/my-dependency
```

When you want to use your local copy, run

```sh
gem local use my-dependency
```

When you want to use the remote version again, run

```sh
gem local ignore my-dependency
```

You can use/ignore multiple gems by supplying a list, or you can use/ignore all at once by not specifying any gem in particular.

If invocations of `bundle config local...` cause your `.gemlocal` file to get out of sync with bundler's settings, run

```sh
gem local rebuild
```

to update your file against bundler's configuration.

For other commands and usage, see

```sh
gem local help
```

For details on a command, for example `install`, run

```sh
gem local help install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christhekeele/gem-local.
