# Advanced developers: Uncomment the following understand more about the RSpec "focus" filter
require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

require "cell"
require "world"
require "patterns"

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

    context "with coordinates" do
      let(:coordinates) { [[1, 1], [2, 2], [3, 3]] }
      subject(:world)   { described_class.new coordinates: coordinates }

      it "creates cells at coordinates" do
        expect(world).to match_cells_at coordinates
      end
    end
  end

  describe "#cells" do
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
    context "when cell does not already exist" do
      subject    { described_class.new }
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
    context "when new cell added to empty world" do
      subject        { described_class.new }
      let(:coord)    { [rand(10).to_i, rand(10).to_i] }
      let(:new_cell) { subject.new_cell_at(*coord) }

      it "returns a cell" do
        expect(new_cell).to be_an_instance_of GameOfLife::Cell
      end

      it "adds a new cell" do
        expect {
          new_cell
        }.to change {
          subject.cells.count
        }.from(0).to 1
      end

      it "adds cell to world" do
        added_cell = subject.new_cell_at(*coord)
        expect(subject.cells).to include added_cell
      end

      it "sets world on cell" do
        expect(new_cell.world).to be subject
      end

      it "adds cell to supplied coordinates" do
        expect(new_cell.x).to be coord.first
        expect(new_cell.y).to be coord.last
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

  describe "#to_s" do
    context "without cells" do
      it "prints empty" do
        expect(described_class.new.to_s).to be_empty
      end
    end

    context "with a single cell" do
      let(:cell)  { random_cell }
      let(:world) { described_class.new cells: [cell] }

      it "prints three lines" do
        expect(world.to_s.lines.count).to be 3
      end

      it "returns the grid" do
        single = [
          "- - -",
          "- # -",
          "- - -"
        ].join("\n")
        expect(world.to_s).to eql single
      end
    end

    context "with multiple cells" do
      let(:world) do
        described_class.new(
          coordinates: GameOfLife::StaticPatterns::Beehive.coordinates
        )
      end

      it "retuns the beehive" do
        beehive = [
          "- - - - - -",
          "- - # # - -",
          "- # - - # -",
          "- - # # - -",
          "- - - - - -"
        ].join("\n")

        expect(world.to_s).to eql beehive
      end
    end
  end

  describe "#step" do
    context "with a single cell" do
      subject(:cell)  { random_cell }
      subject(:world) { described_class.new(cells: [cell]) }

      before do
        world.step
      end

      it "the lone cell dies" do
        expect(world.cells).to be_empty
      end
    end

    shared_examples "a static pattern" do |pattern_class|
      subject(:world)   { described_class.new }
      let(:coordinates) { pattern_class.coordinates }

      before do
        coordinates.each { |coord| world.new_cell_at *coord }

        world.step
      end

      it "#{pattern_class.name} remains static" do
        expect(world).to match_cells_at coordinates
      end
    end

    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Block
    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Beehive
    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Boat

    shared_examples "a repeating pattern" do |pattern_class|
      (0...(pattern_class.cycle.length - 1)).each do |index|
        it "steps from step #{index + 1} to step #{index + 2}" do
          world = GameOfLife::World.new(coordinates: pattern_class.cycle[index])
          world.step

          expect(world).to match_cells_at pattern_class.cycle[index + 1]
        end
      end

      it "cycles back to beginning" do
        world = GameOfLife::World.new(coordinates: pattern_class.cycle.last)
        world.step

        expect(world).to match_cells_at pattern_class.cycle.first
      end

      context "after full period" do
        subject(:world) { GameOfLife::World.new(coordinates: pattern_class.cycle.first) }

        before do
          pattern_class.cycle.length.times { world.step }
        end

        it "returns to begining" do
          expect(world.cells.map(&:coordinates)).to match_array pattern_class.cycle.first
        end
      end
    end

    it_behaves_like "a repeating pattern", GameOfLife::RepeatingPatterns::Blinker
    it_behaves_like "a repeating pattern", GameOfLife::RepeatingPatterns::Pulsar
  end
end
