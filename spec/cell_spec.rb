#Advanced developers: Uncomment the following understand more about the RSpec "focus" filter
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "cell"
require "world"

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

  describe "#remove_neighbours" do
    subject(:cell)  { random_cell }
    let(:neighbour) do
      neighbour = neighbour_cell_for(cell)
      cell.new_cell(neighbour)
      neighbour
    end

    context "with no cells" do
      it "none are removed" do
        cell.remove_neighbours Array.new

        expect(cell.neighbours).to include neighbour
      end
    end

    context "with cells" do
      it "the cells are removed" do
        cell.remove_neighbours([neighbour])

        expect(cell.neighbours).to_not include neighbour
      end
    end
  end
end
