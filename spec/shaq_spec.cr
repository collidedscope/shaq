require "./spec_helper"

describe Shaq do
  it "can create a Game representing the initial position" do
    new_game do
      board.size.should eq 64
      pieces.size.should eq 32
      turn.should eq Side::White
      legal_moves.size.should eq 20
    end
  end
end
