#Advanced developers: Uncomment the following understand more about the RSpec "focus" filter
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "game_of_life"

# The top of your testing block
# More examples of tests can be found here: https://github.com/rspec/rspec-expectations
RSpec.describe GameOfLife::Cell do

  context "when initialized" do
    subject { random_cell }

    it { is_expected.to be_an_instance_of described_class }

    it { is_expected.to respond_to :x }
    it { is_expected.to respond_to :y }
  end

  describe "#coordinates" do
    subject { described_class.new(4, 3) }

    it { is_expected.to respond_to :coordinates }

    it "returns coordinates" do
      expect(subject.coordinates.first).to eql 4
      expect(subject.coordinates.last).to  eql 3
    end
  end

  describe "#world" do
    let(:world) { build_world }

    context "without a world" do
      subject { random_cell }

      it "returns nil" do
        expect(subject.world).to be_nil
      end
    end

    context "when living in a world" do
      subject { random_cell(living_in: world) }

      it "returns the world the cell lives in" do
        expect(subject.world).to be world
      end
    end

    context "when initialized in a world" do
      subject { random_cell }
      let!(:world) { build_world(cells: [subject]) }

      it "knows the world" do
        expect(subject.world).to be world
      end

      it "the world knows it" do
        expect(world.cells).to include subject
      end
    end
  end

  describe "#neighbours" do
    subject { random_cell }
    it { is_expected.to respond_to :neighbours }

    context "with no neighbours" do
      subject { random_cell }

      it "returns empty" do
        expect(subject.neighbours).to be_empty
      end
    end

    context "with a neighbour" do
      subject { random_cell }
      let(:neighbour) { described_class.new(subject.x, subject.y + 1) }

      before do
        subject.new_cell(neighbour)
      end

      it "includes that neighbour" do
        expect(subject.neighbours).to include neighbour
      end
    end
  end

  describe "#new_cell" do
    subject { random_cell }

    it "does not add itself as a neighbour" do
      subject.new_cell(subject)

      expect(subject.neighbours).to_not include subject
    end

    context "when new cell is not a neighbour" do
      let (:far_away) { described_class.new(subject.x + 2, subject.y + 2) }

      before do
        subject.new_cell far_away
      end

      it "is not tracked by cell" do
        expect(subject.neighbours).to_not include far_away
      end
    end

    context "when new cell is a neighbour" do
      let(:other) { neighbour_cell_for(subject) }

      before do
        subject.new_cell other
      end

      it "is tracked by existing cell" do
        expect(subject.neighbours).to include other
      end

      it "tracks existing cell" do
        expect(other.neighbours).to include subject
      end
    end

    context "when many new cells are neighbours" do
      let(:all_neighbours) do
        adjacent_coordinates(subject.x, subject.y).map do |coord|
          described_class.new(*coord)
        end
      end

      before do
        all_neighbours.each { |neighbour| subject.new_cell(neighbour) }
      end

      it "they are tracked by existing cell" do
        expect(subject.neighbours).to match_array all_neighbours
      end

      it "they track existing cell" do
        all_neighbours.each do |neighbour|
          expect(neighbour.neighbours).to include subject
        end
      end
    end
  end

  describe "#influenced_coordinates" do
    subject { random_cell }

    it { is_expected.to respond_to :influenced_coordinates }

    it "returns adjacent coordinates" do
      expect(subject.influenced_coordinates).to match_array adjacent_coordinates(subject.x, subject.y)
    end

    it "does not contain coordinates of neighbourhood cells" do
      neighbour_cells = [neighbour_cell_for(subject), neighbour_cell_for(subject)]
      neighbour_cells.each { |cell| subject.new_cell(cell) }

      expected = Set.new(adjacent_coordinates(subject.x, subject.y)) - neighbour_cells.map(&:coordinates)
      expect(subject.influenced_coordinates).to match_array expected
    end
  end

  describe "#dying?" do
    subject(:world) { build_world }

    context "with no adjacent cells" do
      subject(:cell) { random_cell }

      before do
        world.add_cell(cell)
      end

      it "is true" do
        expect(cell).to be_dying
      end
    end

    context "with one adjacent cells" do
      subject(:cell) { random_cell }
      let(:neighbours) { neighbour_cell_for(cell) }

      it "is true" do
        expect(cell).to be_dying
      end
    end

    context "with two adjacent cells" do
      subject(:cell) { random_cell }
      let(:neighbours) do
        coords = adjacent_coordinates(cell.x, cell.y).sample(2)
        coords.map { |coord| described_class.new *coord }
      end

      before do
        world.add_cell(cell)
        neighbours.each { |neighbour| world.add_cell(neighbour) }
      end

      it "is false" do
        expect(cell).to_not be_dying
      end
    end

    context "with more than three adjacent cells" do
      subject(:cell) { random_cell }
      let(:neighbours) do
        coords = adjacent_coordinates(cell.x, cell.y).sample((4..8).to_a.sample)
        coords.map { |coord| described_class.new *coord }
      end

      before do
        world.add_cell(cell)
        neighbours.each { |neighbour| world.add_cell(neighbour) }
      end

      it "is true" do
        expect(cell).to be_dying
      end
    end
  end
end

RSpec.describe GameOfLife::World do
  it { is_expected.to be_an_instance_of described_class }

  context "when initialized" do
    context "with no cells" do
      subject { described_class.new }

      it "is an empty world" do
        expect(subject.cells).to_not be_any
      end
    end

    context "with cells" do
      subject { described_class.new cells: [random_cell] }

      it "is a world with life!" do
        expect(subject.cells).to be_any
      end
    end
  end

  describe "#cells" do
    it { is_expected.to respond_to :cells }

    context "with no cells" do
      subject { described_class.new }

      it "does not return any" do
        expect(subject.cells).to_not be_any
      end
    end

    context "with a cell" do
      let(:cell) { random_cell }
      subject { described_class.new(cells: [cell]) }

      it "contains the cell" do
        expect(subject.cells).to include cell
      end
    end

    context "with many cells" do
      let(:cells) { [random_cell, random_cell, random_cell] }
      subject { described_class.new(cells: cells) }

      it "contains the cells" do
        expect(subject.cells).to include *cells
      end
    end
  end

  describe "#add_cell" do
    it { is_expected.to respond_to :add_cell }

    context "when cell doesn't already exist" do
      subject    {described_class.new }
      let(:cell) { random_cell }

      before do
        subject.add_cell(cell)
      end

      it "adds the cell to the world" do
        expect(subject.cells).to include cell
      end

      it "sets the cell's world" do
        expect(cell.world).to be subject
      end
    end
  end

  describe "#new_cell_at" do
    it { is_expected.to respond_to :new_cell_at }

    context "when new cell added to empty world" do
      subject     { described_class.new }
      let(:coord) { [rand(10).to_i, rand(10).to_i] }

      it "adds a new cell" do
        expect {
          subject.new_cell_at(*coord)
        }.to change {
          subject.cells.count
        }.from(0).to 1
      end

      it "adds cell to world" do
        new_cell = subject.new_cell_at(*coord)

        expect(subject.cells).to include new_cell
      end

      it "sets world on cell" do
        new_cell = subject.new_cell_at(*coord)

        expect(new_cell.world).to be subject
      end

      it "adds cell to supplied coordinates" do
        subject.new_cell_at(*coord)

        added_cell = subject.cells.first

        expect(added_cell.x).to be coord.first
        expect(added_cell.y).to be coord.last
      end

      it "returns the added cell" do
        new_cell = subject.new_cell_at(*coord)

        expect(new_cell).to be_an_instance_of GameOfLife::Cell
      end
    end

    context "when cell exists at coordinates" do
      subject { described_class.new }
      let!(:existing_cell) { random_cell(living_in: subject) }

      it "does not add a cell" do
        expect {
          subject.new_cell_at(existing_cell.x, existing_cell.y)
        }.to_not change {
          subject.cells.count
        }
      end

      it "returns nil" do
        expect(subject.new_cell_at(existing_cell.x, existing_cell.y)).to be_nil
      end
    end
  end

  describe "#step" do
    context "with a single cell" do
      subject(:cell)  { random_cell }
      subject(:world) { build_world(cells: [cell]) }

      before do
        world.step
      end

      it "the lone cell dies" do
        expect(world.cells).to be_empty
      end
    end

    context "with static patterns" do
      subject(:world) do
        world = build_world
        coordinates.each { |coord| world.new_cell_at *coord }
        world
      end

      before do
        world.step
      end

      # - - - -
      # - # # -
      # - # # -
      # - - - -
      describe "block" do
        let(:coordinates) { [[1, 1], [1, 2], [2, 1],[2, 2,]] }

        it "stays the same" do
          expect(world.cells.map(&:coordinates)).to match_array coordinates
        end
      end

      # - - - - - -
      # - - # # - -
      # - # - - # -
      # - - # # - -
      # - - - - - -
      describe "beehive" do
        let(:coordinates) do
          [
            [1, 3], [1, 4],
            [2, 2], [2, 5],
            [3, 3], [3, 4]
          ]
        end

        it "stays the same" do
          expect(world.cells.map(&:coordinates)).to match_array coordinates
        end
      end

      # - - - - -
      # - # # - -
      # - # - # -
      # - - # - -
      # - - - - -
      describe "boat" do
        let (:coordinates) do
          [
            [1, 3],
            [2, 2], [2, 4],
            [3, 2], [3, 3]
          ]
        end

        it "stays the same" do
          expect(world.cells.map(&:coordinates)).to match_array coordinates
        end
      end
    end
  end
end

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
