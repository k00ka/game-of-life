RSpec::Matchers.define :match_cells_at do |cell_coordinates|
  match do |world|
    expect(world.cells.map(&:coordinates)).to match_array cell_coordinates
  end
end
