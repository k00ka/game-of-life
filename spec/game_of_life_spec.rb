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

    it "returns enumerable of coordinates" do
      expect(subject.coordinates.first).to eql 4
      expect(subject.coordinates.last).to  eql 3
    end
  end

  describe "#world" do
    let (:world) { build_world }

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

def build_world
  GameOfLife::World.new
end
