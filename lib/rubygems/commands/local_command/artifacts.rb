require 'rubygems/command'

class Gem::Commands::LocalCommand < Gem::Command
  
  ARTIFACTS = %w[.bundle .gemlocal].freeze
  
end