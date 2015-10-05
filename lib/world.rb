module GameOfLife
  class World
    def initialize(options = {})
      options = {
        cells:       nil,
        coordinates: nil
      }.merge(options)

      @cells = Array.new

      if options[:cells].respond_to?(:each)
        options[:cells].each { |cell| add_cell(cell) }
      end

      if options[:coordinates].respond_to?(:each)
        options[:coordinates].each { |coord| new_cell_at(*coord) }
      end
    end

    def to_s
      return String.new if cells.empty?

      coordinates = cells.map(&:coordinates).sort_by { |c| c }
      xrange      = (coordinates.first.first..coordinates.last.first).to_a
      yrange      = Range.new(*coordinates.map(&:last).minmax).to_a

      coordinate_grid(coordinates, xrange, yrange)
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
      dying_cells    = cells.select(&:dying?)
      growing_coords = cells.map(&:influenced_coordinates)
                            .flat_map { |set| set.to_a }
                            .group_by { |coord| coord }
                            .keep_if  { |coord, coords| coords.length == 3 }
                            .keys

      cells.each       { |cell| cell.remove_dying_neighbours }
      dying_cells.each { |dying| @cells.delete(dying) }

      growing_coords.each { |coord| new_cell_at *coord }
    end

    private

    def coordinate_grid(coordinates, xrange, yrange)
      grid =
        yrange.reverse.map do |y|
          xrange.map do |x|
            if coordinates.include? [x, y]
              "#"
            else
              "-"
            end
          end
        end

      # pad left and right columns
      grid.each { |row| row.unshift("-") << "-" }

      # pad top and bottom rows
      empty_row = ["-"] * (xrange.size + 2)
      grid.unshift empty_row
      grid << empty_row

      grid.map { |row| row.join(" ") }.join("\n")
    end
  end
end
