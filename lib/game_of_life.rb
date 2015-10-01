require "set"

module GameOfLife

  class Cell
    attr_reader :x, :y, :neighbours
    attr_accessor :world

    def initialize(x, y, options = {})
      @x     = x
      @y     = y
      @world = options[:world] if options[:world]
      @neighbours = Set.new
    end

    def coordinates
      [x, y]
    end

    def new_cell(other)
      @neighbours << other if neighbour?(other)
    end

    private

    def neighbour? other
      Math.sqrt((x - other.x) ** 2 + (y - other.y) ** 2) < 2
    end
  end

  class World
    def initialize(options = {})
      options = {
        cells: Array.new
      }.merge(options)

      @cells = options[:cells]
    end

    def cells
      @cells.dup
    end

    def add_cell(cell)
      cell.world = self

      @cells.each { |cell| cell.new_cell(cell) }

      @cells << cell

      cell
    end

    def new_cell_at(*coordinates)
      if cells.find { |cell| cell.x == coordinates.first && cell.y == coordinates.last }
        nil
      else
        add_cell Cell.new(*coordinates)
      end
    end
  end
end
