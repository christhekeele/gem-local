require 'bundler'

class Gem::Commands::LocalCommand < Gem::Command
  
  def initialize
    super("local", "Toggles bundler's local gem configuration for you.")
  end
  
  def description
    <<-DESC
    The `local` command allows you to save, toggle, and recall per-project usage of `bundle config local.<gem>` settings.
    DESC
  end
  
  def arguments
    <<-ARGS
    add <gem> <path> | Adds or overwrites a local gem configuration.
    show <gem>       | Displays all or a particular local gem configuration.
    remove <gem>     | Removes a local gem configuration.
    on               | Turns local gems on.
    off              | Turns local gems off.
    ignore           | Adds `.gemlocal` artifact to project .gitignore.
    help <cmd>       | Displays this message information about a command.
    ARGS
  end
  
  def cmds
    @cmds ||= {
      "add" =>    "Adds or overwrites a local gem configuration.",
      "show" =>   "Displayes the current local gem configuration.",
      "remove" => "Removes a local gem configuration.",
      "on" =>     "Turns local gems on.",
      "off" =>    "Turns local gems off.",
      "ignore" => "Adds `.gemlocal` artifact to project .gitignore.",
      "help" =>   "Displays this message.",
    }
  end
  
  def execute
    if cmd = options[:args].shift
      if cmds.keys.include? cmd
        send cmd, *options[:args]
      else
        raise "`gem local #{@cmd}` is not a valid command, try:\n" + arguments
      end
    else
      help
    end
  end
  
  # def defaults_str
  #   
  # end
  
  # def usage
  #   
  # end
  
private

# commands

  def add(name = nil, path = nil, *args)
    if name and path and args.empty?
      write_config(config.merge({name => path}))
    else
      raise "`gem local add` takes exactly two arguments: a gem name and the local path to it"
    end
  end

  def show(name = nil, *args)
    if name and args.empty?
      if path = config[name]
        puts path
      else
        raise "`gem local show` could not find `#{name}` in #{find_config}"
      end
    else
      raise "`gem local show` takes exactly one argument: a gem name to remove from the local path list"
    end
  end

  def remove(name = nil, *args)
    if name and args.empty?
      new_config = config
      new_config.delete(name)
      write_config(new_config)
    else
      raise "`gem local remove` takes exactly one argument: a gem name to remove from the local path list"
    end
  end
  
  def on(*args)
    if args.empty?
      config.each do |name, location|
        if Bundler.settings["local.#{name}"] = location
          puts "Activated local gem `#{name}` at `#{location}`"
        end
      end
    else
      raise "`gem local on` takes no arguments"
    end    
  end
  
  def off(*args)
    if args.empty?
      config.each do |name, location|
        if Bundler.settings.delete "local.#{name}"
          puts "Deactivated local gem `#{name}` from `#{location}`"
        end
      end
    else
      raise "`gem local off` takes no arguments"
    end    
  end
  
  def ignore(*args)
    if args.empty?
      File.open(find_file('.gitignore'), "a+") do |file|
        file.puts '.gemlocal'
      end
    else
      raise "`gem local ignore` takes no arguments"
    end    
  end
  
  def help(cmd = nil, *args)
    if not cmd and args.empty?
      puts description + "\n" + arguments
    elsif cmd
      puts "USAGE: " + cmds[cmd]
    end    
  end
  
# plumbing

  def config
    @config ||= read_config
  end

  def read_config
    File.open(find_config, "a+") do |file|
      lines = file.readlines
      config = Hash[
        lines.reject do |line|
          line.start_with? "#" or line.strip.empty?
        end.map do |line|
          name, location, *args = line.strip.split
          if name and location and args.empty?
            [name, location]
          else
            raise "`gem local` config in `#{path}` is corrupt, each non-empty non-commented line must contain a gem name and the local path to that gem, separated by a space"
          end
        end
      ]
    end
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
    File.open(find_config, "a+") do |file|
      config.each do |name, location|
        if name and location
          file.puts "#{name} #{location}"
        end
      end
    end
  end
  
end