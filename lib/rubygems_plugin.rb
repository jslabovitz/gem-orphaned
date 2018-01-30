require 'rubygems/command_manager'
require 'rubygems/command'
require 'rubygems/uninstaller'

require 'gem-orphaned/orphaned_command'
require 'gem-orphaned/version'

Gem::CommandManager.instance.register_command(:orphaned)