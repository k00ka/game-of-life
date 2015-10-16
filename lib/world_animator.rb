class WorldAnimator
  def initialize(world, steps = 10, delay = 1)
    @world = world
    @steps = steps
    @delay = delay
  end

  def animate
    row_widths    = []
    iteration     = 0

    while iteration < @steps
      clear_previous(row_widths)

      output = @world.to_s
      output += "\n" unless output.end_with?("\n")

      print output
      sleep @delay

      row_widths = @world.to_s.lines.map(&:length)
      @world.step
      iteration += 1
    end
  end

  private

  def clear_previous row_widths
    row_widths.reverse.each do |width|
      # move up a row
      print "\e[1A"

      # clear whole row
      print "\e[2K"

      # move cursor to leftmost
      print "\e[#{width}D"
    end
  end
end
