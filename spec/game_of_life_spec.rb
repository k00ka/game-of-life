#Advanced developers: Uncomment the following understand more about the RSpec "focus" filter
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "game_of_life"

# The top of your testing block
# More examples of tests can be found here: https://github.com/rspec/rspec-expectations
RSpec.describe GameOfLife::Cell do

  context "when initialized" do
    subject { described_class.new(1, 1) }

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

  def random_cell(range = (-10..10))
    points = range.to_a

    GameOfLife::Cell.new(points.sample, points.sample)
  end
end
