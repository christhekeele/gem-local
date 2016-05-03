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
    add    | Adds a local gem configuration.
    remove | Removes a local gem configuration.
    on     | Turns local gems on.
    off    | Turns local gems off.
    toggle | Toggles local gems.
    ARGS
  end
  
  def execute
    # require 'pry'; binding.pry
  end
  
  def defaults_str
    
  end
  
  def usage
    
  end
  
end