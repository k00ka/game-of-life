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
