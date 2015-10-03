require 'set'

class Board
  def initialize(height, width)
    @height = height
    @width = width
    @live_cells = Set.new
  end

  def set_cell_alive(i,j)
    @live_cells << coord_to_key(i,j) if valid_coord?(i,j)
  end

  def dead?
    @live_cells.empty?
  end

  def step
    new_board = Board.new(@height, @width)
    cells_to_review = @live_cells.map { |k| i,j = key_to_coord(k); neighbour_addresses(i,j) }.flatten(1).uniq
    cells_to_review.each do |i,j|
      new_board.set_cell_alive(i,j) if cell_alive_in_next_step?(i,j)
    end
    new_board
  end

  def show
    (0..@height-1).each do |i|
      (0..@width-1).each do |j|
        print cell_alive?(i,j) ? '#' : '-'
      end
      puts
    end
  end

private
  def cell_alive?(i,j)
    @live_cells.include?(coord_to_key(i,j))
  end

  def neighbour_addresses(i,j)
    [[i-1,j-1],[i-1,j],[i-1,j+1],[i,j-1],[i,j+1],[i+1,j-1],[i+1,j],[i+1,j+1]]
  end

  def live_neighbour_count(i,j)
    neighbour_addresses(i,j).select { |i,j| cell_alive?(i,j) }.count
  end

  def cell_alive_in_next_step?(i,j)
   if cell_alive?(i,j)
     return [2,3].include?(live_neighbour_count(i,j))
   else
     return live_neighbour_count(i,j) == 3
   end
  end

  def coord_to_key(i,j)
    [i,j].join(',')
  end

  def key_to_coord(k)
    k.split(',').map(&:to_i)
  end

  def valid_coord?(i,j)
    (0..@height-1).include?(i) && (0..@width-1).include?(j)
  end
end
