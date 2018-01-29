class Gem::Commands::OrphanedCommand < Gem::Command

  DefaultPreferredGems = %w{
    bundler
    gem-orphaned
    rubygems-update
  }

  def initialize
    super 'orphaned', %q{Show orphaned gems}
    add_option('--sudo', "Run sudo before 'gem uninstall <gem>'") do |value, options|
      options[:sudo] = true
    end
  end

  def execute
    read_preferred_gems
    read_gems
    show_orphaned_gems
  end

  def read_preferred_gems
    @preferred_gems = DefaultPreferredGems.dup
    preferred_gems_path = File.expand_path('~/.preferred_gems')
    if File.exist?(preferred_gems_path)
      @preferred_gems += File.read(preferred_gems_path).split("\n")
    end
  end

  def read_gems
    @gems = {}
    Gem::Specification.each do |spec|
      unless @preferred_gems.include?(spec.name)
        @gems[spec.name] ||= []
        @gems[spec.name] << spec
      end
    end
    @gems.delete_if do |name, specs|
      specs.find(&:default_gem?)
    end
  end

  def show_orphaned_gems(&block)
    @gems.each do |name, specs|
      specs.select { |s| s.dependent_gems.empty? }.each { |s| show_spec(s) }
    end
  end

  def show_spec(spec)
    puts "#{spec.name} (#{spec.version})"
    loop do
      print "Remove #{spec.name}? [Yn] "
      case STDIN.gets.chomp
      when 'y', ''
        args = []
        args += ['sudo'] if options[:sudo]
        args += ['gem', 'uninstall', spec.name]
        system(*args)
        break
      when 'n'
        break
      else
        puts '?'
      end
    end
  end

end