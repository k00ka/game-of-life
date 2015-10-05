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
        expect(world.cells.map(&:coordinates)).to match_array coordinates
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

  describe "#to_s" do
    context "without cells" do
      it "prints empty" do
        expect(build_world.to_s).to be_empty
      end
    end

    context "with a single cell" do
      let(:cell)  { random_cell }
      let(:world) { build_world(cells: [cell]) }

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
      let(:world) { build_world }

      before do
        GameOfLife::StaticPatterns::Beehive.coordinates.each do |coord|
          world.new_cell_at(*coord)
        end
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
      subject(:world) { build_world(cells: [cell]) }

      before do
        world.step
      end

      it "the lone cell dies" do
        expect(world.cells).to be_empty
      end
    end

    shared_examples "a static pattern" do |pattern_class|
      subject(:world)   { build_world }
      let(:coordinates) { pattern_class.coordinates }

      before do
        coordinates.each { |coord| world.new_cell_at *coord }

        world.step
      end

      it "#{pattern_class.name} remains static" do
        expect(world.cells.map(&:coordinates)).to match_array coordinates
      end
    end

    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Block
    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Beehive
    it_behaves_like "a static pattern", GameOfLife::StaticPatterns::Boat

    shared_examples "a repeating pattern" do |pattern_class|
      (0...(pattern_class.cycle.length - 1)).each do |index|
        it "steps from step #{index + 1} to step #{index + 2}" do
          world = build_world coordinates: pattern_class.cycle[index]
          world.step

          expect(world.cells.map(&:coordinates)).to match_array pattern_class.cycle[index + 1]
        end
      end

      it "cycles back to beginning" do
        world = build_world coordinates: pattern_class.cycle.last
        world.step

        expect(world.cells.map(&:coordinates)).to match_array pattern_class.cycle.first
      end
    end

    it_behaves_like "a repeating pattern", GameOfLife::RepeatingPatterns::Blinker
    it_behaves_like "a repeating pattern", GameOfLife::RepeatingPatterns::Pulsar
  end
end
