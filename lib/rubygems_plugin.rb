require 'rubygems/command_manager'
require 'rubygems/command'
require 'rubygems/uninstaller'

require_relative 'gem-orphaned_command'

Gem::CommandManager.instance.register_command(:orphaned)