module GameOfLife

  class Cell
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def coordinates
      [x, y]
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
  end
end
