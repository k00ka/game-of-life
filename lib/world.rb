module GameOfLife
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
