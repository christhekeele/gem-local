require 'bundler'

class Gem::Commands::LocalCommand < Gem::Command
  
  class Setting
    attr_accessor :location, :status
    def initialize(location,  status = "on")
      @location, @status = location, status
    end
  end
  
  def initialize
    super("local", "A configuration manager for bundler's local gem settings.")
  end
  
  def description
    <<-DESC
The `gem local` command allows you to save, toggle, and recall per-project usage of `bundle config local.<gem>` settings.
    DESC
  end
  
  def arguments
    <<-ARGS
add <gem> <path> | Adds or overwrites a local gem configuration.
show [gem]       | Displays all or a particular local gem configuration.
remove <gem>     | Removes a local gem from `gem local` configuration.
on [gem, ...]    | Turns local gem(s) on.
off [gem, ...]   | Turns local gem(s) off.
ignore           | Adds `.gemlocal` artifact to project .gitignore.
help [cmd]       | Displays help information.
    ARGS
  end
  
  def usage
    "#{program_name} subcommand <gem> <path>" + "\n" + arguments
  end
  
  def execute
    if cmd = options[:args].shift
      if available_cmds.include? cmd
        public_send cmd, *options[:args]
      else
        raise "`gem local #{cmd}` is not a valid command, try:\n" + arguments
      end
    else
      help
    end
  end

# COMMANDS

  def add(name = nil, location = nil, *args)
    if name and location and args.empty?
      setting = Setting.new(location)
      if bundler_add name, setting
        update_config(name, :status, "on")
      end
    else
      arity_error __method__
    end
  end
  alias_method :new, :add

  def show(name = nil, *args)
    if not name and args.empty?
      config.each do |name, setting|
        puts show_setting_for(name, setting)
      end
    elsif name
      if setting = config[name]
        puts show_setting_for(name, setting)
      else
        raise "`gem local show` could not find `#{name}` in:\n#{find_config}"
      end
    else
      arity_error __method__
    end
  end
  alias_method :status, :show

  def remove(name = nil, *args)
    if name and args.empty?
      new_config = config
      new_config.delete(name)
      write_config(new_config)
    else
      arity_error __method__
    end
  end
  alias_method :delete, :remove
  
  def on(*names)
    if names.empty?
      config.each do |name, setting|
        if bundler_add name, setting
          update_config(name, :status, "on")
        end
      end
    else
      names.each do |name|
        if setting = config[name]
          if bundler_add name, setting
            update_config(name, :status, "on")
          else
            raise "Could not activate gem, make sure `bundle config local.#{name}` #{setting.location} succeeds"
          end
        else
          raise "`gem local on` could not find `#{name}` in:\n#{find_config}"
        end
      end
    # else
    #   arity_error __method__
    end    
  end
  alias_method :use, :on
  alias_method :activate, :on
  alias_method :enable, :on
  alias_method :renable, :on
  alias_method :reactivate, :on
  
  def off(*names)
    if names.empty?
      config.each do |name, setting|
        if bundler_remove name, setting
          update_config(name, :status, "off")
        end
      end
    else
      names.each do |name|
        if setting = config[name]
          if bundler_add name, setting
            update_config(name, :status, "off")
          else
            raise "Could not deactivate gem, make sure `bundle config --delete local.#{name}` succeeds"
          end
        else
          raise "`gem local off` could not find `#{name}` in:\n#{find_config}"
        end
      end
    # else
    #   arity_error __method__
    end    
  end
  alias_method :ignore, :off
  alias_method :deactivate, :off
  alias_method :disable, :off
  
  def install(*args)
    if args.empty?
      File.open(find_file('.gitignore'), "a+") do |file|
        %w[.bundle .gemlocal].each do |ignorable|
          unless file.lines.any?{ |line| line.include? ignorable }
            file.puts ignorable 
          end
        end
      end
    else
      arity_error __method__
    end    
  end
  alias_method :init, :install
  
  def help(cmd = nil, *args)
    if not cmd and args.empty?
      puts description + "\n" + arguments
    elsif cmd
      puts info_for(__method__)
    else
      arity_error __method__
    end    
  end
  
private

# COMMANDS

  def cmds
    @cmds ||= {
      "add"    => {
        description: "Adds or overwrites a local gem configuration and activates the gem from sourcein bundler.",
        usage: "add <gem> <path>",
        arguments: "takes exactly two arguments",
        aliases: %w[new],
      },
      "show"   => {
        description: "Displays the current local gem configuration, or the specified gem's config.",
        usage: "show [gem]",
        arguments: "takes zero or one arguments",
        aliases: %w[status],
      },
      "remove" => {
        description: "Remove a local gem from `gem local` management.",
        usage: "remove <gem>",
        arguments: "takes exactly one argument",
        aliases: %w[delete],
      },
      "on"     => {
        description: "Activates all registered local gems, or the specified gem, in bundler.",
        usage: "on [gem]",
        arguments: "takes any number of arguments",
        aliases: %w[use activate enable renable reactivate],
      },
      "off"    => {
        description: "Deactivates all registered local gems, or the specified gem, in bundler.",
        usage: "off [gem]",
        arguments: "takes any number of arguments",
        aliases: %w[ignore deactivate disable],
      },
      "install" => {
        description: "Adds `.gemlocal` and `.bundle` artifacts to project `.gitignore`",
        usage: "install",
        arguments: "takes zero arguments",
        aliases: %w[init],
      },
      "help"   => {
        description: "Displays help information, either about `gem local` or a `gem local` subcommand.",
        usage: "help [cmd]",
        arguments: "takes zero or one arguments",
      },
    }
  end
  
  def available_cmds
    cmds.map do |cmd, info|
      [cmd, info[:aliases]]
    end.flatten.compact
  end

# FORMATTING

  def show_setting_for(name, setting)
    "%-4.4s #{name} @ #{setting.location}" % "#{setting.status}:"
  end

  def info_for(cmd)
    info = cmds[cmd.to_s]
    usage_for(info) + "\n" + aliases_for(info) + "\n" + description_for(info)
  end
  
  def usage_for(info)
    "USAGE: #{info[:usage]}"
  end
  
  def aliases_for(info)
    "aliases: "+ Array(info[:aliases]).flatten.join(', ')
  end

  def description_for(info)
    info[:description]
  end
  
  def arity_error(cmd)
    info = cmds[cmd.to_s]
    raise "`gem local #{cmd}` #{info[:arguments]}" + "\n" + info_for(cmd)
  end
  
# PLUMBING

  def config
    @config ||= read_config
  end

  def read_config
    File.open(find_config) do |file|
      lines = file.readlines
      config = Hash[
        lines.reject do |line|
          line.start_with? "#" or line.strip.empty?
        end.map do |line|
          status, name, location, *args = line.strip.split
          if status and name and location and args.empty?
            [name, Setting.new(location, status)]
          else
            raise "`gem local` config in `#{path}` is corrupt, each non-empty non-commented line must contain a status, a gem name, and the local path to that gem, separated by spaces\nerror at:\n#{line}"
          end
        end
      ]
    end
  end
  
  def touch_file(path)
    FileUtils.touch(path).unshift
  end

  def find_file(path)
    if File.exists? path
      path
    else
      touch_file path
    end
  end
  
  def find_config
    find_file Bundler.default_gemfile.dirname + '.gemlocal'
  rescue Bundler::GemfileNotFound
    raise "`gem local` could not locate a `Gemfile` file, which it uses to determine the root of your project"
  end
  
  def write_config(config)
    File.open(find_config, "w") do |file|
      config.each do |name, setting|
        file.puts "%-3.3s #{name} #{setting.location}" % setting.status
      end
    end
  end
  
  def update_config(name, field, value)
    new_config = config
    new_setting = new_config[name]
    new_setting.send(:"#{field}=", value)
    new_config[name] = new_setting
    write_config new_config
    puts show_setting_for(name, new_setting)
  end
  
  def bundler_add(name, setting)
    Bundler.settings["local.#{name}"] = setting.location
    !! Bundler.settings["local.#{name}"]
  end
  
  def bundler_remove(name, setting)
    Bundler.settings["local.#{name}"] = nil
    not Bundler.settings["local.#{name}"]
  end
  
end