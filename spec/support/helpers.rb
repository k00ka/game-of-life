module Helpers
  def random_cell(options = {})
    options = {
      range: (-10..10),
      living_in: nil
    }.merge(options)

    points = options[:range].to_a

    cell = GameOfLife::Cell.new(points.sample, points.sample)

    options[:living_in].add_cell(cell) if options[:living_in]

    cell
  end

  def neighbour_cell_for(cell)
    GameOfLife::Cell.new *adjacent_coordinates(cell.x, cell.y).sample
  end

  def adjacent_coordinates(x, y)
    [
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

  def build_world(options = {})
    GameOfLife::World.new(options)
  end
end
