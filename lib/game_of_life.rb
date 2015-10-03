require_relative './board'

class GameOfLife
  def initialize(height = 20, width = 40, seed_count = height*width/4)
    @board = Board.new(height, width)
    seed_count.times { @board.set_cell_alive((rand * height).to_i, (rand * width).to_i) }
    @iteration = 0
  end

  def run
    begin
      show_board
      sleep(1.0/24.0)
      @board = @board.step
      @iteration += 1
    end until @board.dead?
    show_board
    puts "He's dead, Jim."
  end
  
private
  def clear_screen
    puts "\e[H\e[2J"
  end

  def show_board
    clear_screen
    @board.show
    puts "Iteration #{@iteration}"
  end
end
