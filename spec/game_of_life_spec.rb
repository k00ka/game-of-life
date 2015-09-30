#Advanced developers: Uncomment the following understand more about the RSpec "focus" filter
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'game_of_life'

# The top of your testing block
# More examples of tests can be found here: https://github.com/rspec/rspec-expectations
RSpec.describe GameOfLife, "#something" do

  it "returns an empty board given an empty board" do
    expect(GameOfLife.step(empty_board)).to eq(empty_board)
  end

  # more tests go here
end

