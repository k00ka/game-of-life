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
      return if other == self

      if neighbour?(other) && !neighbours.include?(other)
        @neighbours << other
        other.new_cell(self)
      end
    end

    def influenced_coordinates
      adjacent_coordinates - Set.new(neighbours.map(&:coordinates))
    end

    def dying?
      case neighbours.count
      when 0, 1
        true
      when 2, 3
        false
      else
        true
      end
    end

    private

    def neighbour? other
      Math.sqrt((x - other.x) ** 2 + (y - other.y) ** 2) < 2
    end

    def adjacent_coordinates
      Set.new [
        [x + 1, y],
        [x - 1, y],
        [x, y + 1],
        [x, y - 1],
        [x + 1, y + 1],
        [x + 1, y - 1],
        [x - 1, y + 1],
        [x - 1, y - 1],
      ]
    end
  end

  class World
    def initialize(options = {})
      options = {
        cells: Array.new
      }.merge(options)

      @cells = Array.new

      if options[:cells].respond_to?(:each)
        options[:cells].each { |cell| add_cell(cell) }
      end
    end

    def cells
      @cells.dup
    end

    def add_cell(cell)
      cell.world = self

      @cells.each { |existing_cell| existing_cell.new_cell(cell) }

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

    def step
      dying_cells = cells.select(&:dying?)

      dying_cells.each { |dying| @cells.delete(dying) }
    end
  end
end
