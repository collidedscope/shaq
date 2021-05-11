require "./spec_helper"

describe Shaq do
  it "can create a Game representing the initial position" do
    subject Game.new do
      board.size.should eq 64
      pieces.size.should eq 32
      turn.should eq Side::White
      legal_moves.size.should eq 20
    end
  end
end

describe Game do
  it "updates the state of the board as moves are played" do
    subject Game.new do
      board[D4].should be_nil
      ply "d4"
      board[D4].should be_a Pawn
      board[D2].should be_nil

      board[F6].should be_nil
      ply "Nf6"
      board[F6].should be_a Knight
      board[G8].should be_nil
    end
  end
end
