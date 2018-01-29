class Gem::Commands::OrphanedCommand < Gem::Command

  DefaultPreferredGems = %w{
    rubygems-update
  }

  def initialize
    @preferred_gems = DefaultPreferredGems.dup
    super 'orphaned', %q{Show orphaned gems}
  end

  def execute
    read_preferred_gems
    read_gems
    show_orphaned_gems
  end

  def read_preferred_gems
    prefered_gems_path = File.expand_path('~/.preferred_gems')
    if File.exist?(prefered_gems_path)
      @preferred_gems += File.read().split("\n")
    end
  end

  def read_gems
    gems = {}
    Gem::Specification.each do |spec|
      unless @preferred_gems.include?(spec.name)
        gems[spec.name] ||= []
        gems[spec.name] << spec
      end
    end
    gems.delete_if do |name, specs|
      specs.find(&:default_gem?)
    end
    gems
  end

  def show_orphaned_gems(&block)
    gems.each do |name, specs|
      specs.select { |s| s.dependent_gems.empty? }.each { |s| show_spec(s) } }
    end
  end

  def show_spec(spec)
    puts "#{spec.name} (#{spec.version})"
    loop do
      print "Remove #{spec.name}? [Yn] "
      case STDIN.gets.chomp
      when 'y', ''
        system('gem', 'uninstall', spec.name)
        break
      when 'n'
        break
      else
        puts '?'
      end
    end
  end

end