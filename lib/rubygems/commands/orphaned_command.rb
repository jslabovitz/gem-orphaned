require 'rubygems/command'
require 'set'

class Gem::Commands::OrphanedCommand < Gem::Command

  PreferredGemsFile = File.expand_path('~/.preferred_gems')

  def initialize
    super 'orphaned', 'Show orphaned gems'
  end

  def execute
    read_gems
    read_preferred_gems
    check_preferred_gems
    show_orphaned_gems
  end

  def read_gems
    @gems = {}
    Gem::Specification.each do |spec|
      @gems[spec.name] ||= []
      @gems[spec.name] << spec
    end
  end

  def read_preferred_gems
    @preferred_gems = []
    @preferred_gems += default_gems
    if File.exist?(PreferredGemsFile)
      data = File.read(PreferredGemsFile)
      lines = data.split("\n").map { |s| s.sub(/#.*/, '').strip }.reject(&:empty?)
      @preferred_gems += lines
    end
    @preferred_gems.uniq!
  end

  def check_preferred_gems
    @preferred_gems.each do |name|
      unless @gems[name]
        puts "#{name}: in preferred list but not installed"
      end
    end
  end

  def show_orphaned_gems
    orphaned_gems.each do |spec|
      puts "#{spec.name} (#{spec.version}): orphaned"
    end
  end

  def default_gems
    @gems.select do |name, specs|
      specs.find(&:default_gem?)
    end.keys
  end

  def orphaned_gems
    names = @gems.keys - @preferred_gems
    @gems.values_at(*names).map do |specs|
      specs.select { |s| s.dependent_gems.empty? }
    end.flatten
  end

end