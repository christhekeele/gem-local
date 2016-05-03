require 'bundler'

class Gem::Commands::LocalCommand < Gem::Command
  
  class Setting
    attr_accessor :location, :status
    def initialize(location,  status = "off")
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
add <gem> <path>  | Adds or overwrites a local gem configuration.
status [gem]      | Displays all or a particular local gem configuration.
remove <gem>      | Removes a local gem from `gem local` configuration.
use [gem, ...]    | Enables local gem(s).
ignore [gem, ...] | Disables local gem(s).
rebuild           | Regenerates your `.gemlocal` from bundle config state.
install           | Adds `.gemlocal` artifact to project `.gitignore`.
help [cmd]        | Displays help information.
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
        update_config(name, :status, setting.status)
      end
    else
      arity_error __method__
    end
  end
  alias_method :new, :add

  def status(name = nil, *args)
    if not name and args.empty?
      config.each do |name, setting|
        puts show_setting_for(name, setting)
      end
    elsif name
      if setting = config[name]
        puts show_setting_for(name, setting)
      else
        raise "`gem local #{__method__}` could not find `#{name}` in:\n#{find_config}"
      end
    else
      arity_error __method__
    end
  end
  alias_method :show, :status

  def remove(name = nil, *args)
    if name and args.empty?
      config.delete(name)
      write_config(config)
    else
      arity_error __method__
    end
  end
  alias_method :delete, :remove
  
  def use(*names)
    names = config.values if names.empty?
    names.each do |name|
      if setting = config[name]
        if bundler_add name, setting
          update_config(name, :status, "on")
        else
          raise "Could not activate gem, make sure `bundle config local.#{name}` #{setting.location} succeeds"
        end
      else
        raise "`gem local #{__method__}` could not find `#{name}` in:\n#{find_config}"
      end
    end
  end
  alias_method :on, :use
  alias_method :activate, :use
  alias_method :enable, :use
  alias_method :renable, :use
  alias_method :reactivate, :use
  
  def ignore(*names)
    names = config.values if names.empty?
    names.each do |name|
      if setting = config[name]
        if bundler_remove name, setting
          update_config(name, :status, "off")
        else
          raise "Could not deactivate gem, make sure `bundle config --delete local.#{name}` succeeds"
        end
      else
        raise "`gem local #{__method__}` could not find `#{name}` in:\n#{find_config}"
      end
    end
  end
  alias_method :off, :ignore
  alias_method :deactivate, :ignore
  alias_method :disable, :ignore
  
  def rebuild(*args)
    if args.empty?
      config = read_config.dup
      clear_config_cache
      File.open(find_config, "w") do |file|
        config.each do |name, old_setting|
          if setting = bundler_value(name, old_setting)
            file.puts config_for(name, setting.location, setting.status)
          end
        end
      end
      show
    else
      arity_error __method__
    end    
  end
  
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
      "status" => {
        description: "Displays the current local gem configuration, or the specified gem's config.",
        usage: "status [gem]",
        arguments: "takes zero or one arguments",
        aliases: %w[show],
      },
      "remove" => {
        description: "Remove a local gem from `gem local` management.",
        usage: "remove <gem>",
        arguments: "takes exactly one argument",
        aliases: %w[delete],
      },
      "use"    => {
        description: "Activates all registered local gems, or the specified gem, in bundler.",
        usage: "use [gem]",
        arguments: "takes any number of arguments",
        aliases: %w[on activate enable renable reactivate],
      },
      "ignore"    => {
        description: "Deactivates all registered local gems, or the specified gem, in bundler.",
        usage: "ignore [gem]",
        arguments: "takes any number of arguments",
        aliases: %w[off deactivate disable],
      },
      "rebuild" => {
        description: "Regenerates your local `.gemlocal` file from the bundle config if they get out of sync.",
        usage: "rebuild",
        arguments: "takes zero arguments",
        aliases: %w[],
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
        aliases: %w[],
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
  
  def config_for(name, location, status)
    "%-3.3s #{name} #{location}" % status
  end
  
  def arity_error(cmd)
    info = cmds[cmd.to_s]
    raise "`gem local #{cmd}` #{info[:arguments]}" + "\n" + info_for(cmd)
  end
  
# PLUMBING

  def config
    @config ||= read_config
  end
  
  def clear_config_cache
    @config = nil
  end

  def read_config
    File.open(find_config) do |file|
      config = Hash[
        file.readlines.reject do |line|
          line.start_with? "#" or line.strip.empty?
        end.map do |line|
          status, name, location, *args = line.strip.split
          if status and name and location and args.empty?
            [name, Setting.new(location, status)]
          else
            raise "`gem local` config in `#{find_config}` is corrupt, each non-empty non-commented line must contain a status, a gem name, and the local path to that gem, separated by spaces\nerror at:\n#{line}"
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
        file.puts config_for(name, setting.location, setting.status)
      end
    end
  end
  
  def update_config(name, field, value)
    new_setting = config[name]
    new_setting.send(:"#{field}=", value)
    config[name] = new_setting
    write_config config
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
  
  def bundler_value(name, setting)
    if new_setting = bundler_values[name]
      new_setting
    else
      setting.status = "off"
      setting
    end
  end
  
  def bundler_values
    @bundler_values ||= Hash[
      Bundler.settings.send(:load_config, Bundler.settings.send(:local_config_file)).select do |setting, value|
        setting =~ /^BUNDLE_LOCAL__/
      end.map do |setting, value|
        [ setting[/^BUNDLE_LOCAL__(?<name>.*?)$/, :name].downcase, value ]
      end.map do |name, location|
        [ name, Setting.new(location, "on")]
      end
    ]
  end
  
end