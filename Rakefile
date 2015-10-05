require_relative "lib/cell"
require_relative "lib/patterns"
require_relative "lib/world"

desc 'Run the flog metrics tool on the GameOfLife class'
task :flog do
  system 'flog -agme lib/game_of_life.rb | grep -v lib/game_of_life | tee /dev/tty | pbcopy'
end

desc 'Highlight source code from the clipboard back onto the clipboard (suitable for Keynote)'
task :keynote do
  system 'pbpaste | highlight --out-format rtf --font-size 24 --font Menlo --plug-in highlight/rspec.lua --config-file highlight/twilight.theme --style twilight --src-lang ruby | pbcopy'
end

desc 'Highlight source code from the clipboard back onto the clipboard (suitable for Pages)'
task :pages do
  system 'pbpaste | highlight --out-format rtf --font-size 10 --font Menlo --src-lang ruby --line-numbers | pbcopy'
end

desc 'Run mutation testing to assess the characterization'
task :mutate do
  system 'mutant --include lib --require game_of_life --use rspec .score'
end

desc 'Approve the received characterization'
task :approve do
  mv received, approved
end

desc "shows known patterns"
task :show, :pattern do |t, args|
  pattern_map = known_patterns_map

  unless pattern_map.include? args[:pattern]
    puts "Pattern #{args[:pattern]} not found!"
    next
  end

  pattern = pattern_map[args[:pattern]]
  if pattern.respond_to?(:cycle)
    pattern.cycle.each do |coordinates|
      puts GameOfLife::World.new(coordinates: coordinates).to_s
      puts
    end
  elsif pattern.respond_to?(:coordinates)
    puts GameOfLife::World.new(coordinates: pattern.coordinates).to_s
  end
end

desc "generates known patterns"
task :generate, :pattern do |t, args|
  pattern_map = known_patterns_map

  unless pattern_map.include? args[:pattern]
    puts "Pattern #{args[:pattern]} not found!"
    next
  end

  pattern = pattern_map[args[:pattern]]
  if pattern.respond_to?(:cycle)
    world = GameOfLife::World.new(coordinates: pattern.cycle.first)
    puts world.to_s
    puts ""

    pattern.cycle.length.times do
      world.step
      puts world.to_s
      puts ""
    end
  elsif pattern.respond_to?(:coordinates)
    world = GameOfLife::World.new(coordinates: pattern.coordinates)
    puts world.to_s
  end
end

desc "prints generated vs expected patterns for RepeatingPatterns"
task :compare, :pattern do |t, args|
  pattern_map = known_patterns_map

  unless pattern_map.include? args[:pattern]
    puts "Pattern #{args[:pattern]} not found!"
    next
  end

  pattern = pattern_map[args[:pattern]]

  unless pattern.respond_to?(:cycle)
    puts "Pattern #{args[:pattern]} is not repeating!"
    next
  end

  pattern.cycle.each_with_index do |coordinates, index|
    expected = GameOfLife::World.new(coordinates: pattern.cycle[index])

    actual   = GameOfLife::World.new(coordinates: pattern.cycle.first)
    index.times { actual.step }

    print_comparison(expected, actual)
  end

  first_step = GameOfLife::World.new(coordinates: pattern.cycle.first)
  full_cycle = GameOfLife::World.new(coordinates: pattern.cycle.first)
  pattern.cycle.length.times { full_cycle.step }

  print_comparison(first_step, full_cycle)
end

private

def print_comparison(expected, actual)
  expected_data = expected.to_s.split("\n")
  actual_data   = actual.to_s.split("\n")

  expected_data.unshift("expected:".ljust(expected_data.first.length, " "))
  actual_data.unshift("actual:".ljust(actual_data.first.length, " "))

  puts actual_data.zip(expected_data).map { |row| row.join("\t") }.join("\n")
  puts
end

def known_patterns_map
  pattern_map = Hash.new
  [GameOfLife::StaticPatterns, GameOfLife::RepeatingPatterns].each do |pattern_namespace|
    pattern_namespace.constants.each do |pattern_sym|
      pattern_map[pattern_sym.to_s.downcase] = pattern_namespace.const_get(pattern_sym)
    end
  end
  pattern_map
end

def received
  characterization_filename :received
end

def approved
  characterization_filename :approved
end

def characterization_filename(status)
  "spec/fixtures/approvals/game_of_life/knows_how_to_play.#{status}.txt"
end
