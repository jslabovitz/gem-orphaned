require 'set'

class Gem::Commands::OrphanedCommand < Gem::Command

  PreferredGemsFile = File.expand_path('~/.preferred_gems')
  DefaultPreferredGems = %w{
    bundler
    gem-orphaned
    rubygems-update
  }

  def initialize
    super 'orphaned', 'Show orphaned gems'
  end

  def execute
    read_preferred_gems
    read_gems
    show_orphaned_gems
    save_preferred_gems
  end

  def read_preferred_gems
    @preferred_gems = Set.new(DefaultPreferredGems)
    if File.exist?(PreferredGemsFile)
      @preferred_gems += File.read(PreferredGemsFile).split("\n").reject(&:empty?)
    end
    @dirty = false
  end

  def add_preferred_gem(spec)
    @preferred_gems << spec.name
    @dirty = true
  end

  def save_preferred_gems
    if @dirty
      File.open(PreferredGemsFile, 'w') do |io|
        @preferred_gems.sort.each { |name| io.puts name }
      end
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
    loop do
      print "#{spec.name} (#{spec.version}) [remove, Ignore, add]? "
      case STDIN.gets.chomp
      when 'r'
        Gem::Uninstaller.new(spec.name).uninstall
        break
      when 'i', ''
        break
      when 'a'
        add_preferred_gem(spec)
        break
      else
        puts '?'
      end
    end
  end

end