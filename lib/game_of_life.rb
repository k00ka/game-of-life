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
end
