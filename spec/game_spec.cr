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

  it "knows when the King is in danger" do
    subject Game.new do
      ply %w[e4 d5 Bb5]
      san_history.last.should eq "Bb5+"
      check?.should be_true
    end
  end

  it "knows when the King has nowhere to go" do
    subject Game.new do
      ply %w[f3 e6 g4 Qh4#]
      checkmate?.should be_true
    end
  end

  it "knows about capturing en passant" do
    subject Game.from_fen "5B2/6p1/8/4RP1k/4pK1N/6P1/4qP2/8 b - - 0 1" do
      # https://en.wikipedia.org/wiki/En_passant#Unusual_examples
      # The position:
      # . . . . . B . .
      # . . . . . . p .
      # . . . . . . . .
      # . . . . R P . k
      # . . . . p K . N
      # . . . . . . P .
      # . . . . q P . .
      # . . . . . . . .

      # Black double-moves the Pawn, attacking and very nearly mating the King.
      ply "g5"

      # White's only response is to capture the Pawn en passant...
      ep_target.should eq G6
      legal_moves.should eq [{F5, G6}]
      ply F5, G6

      # ... which happens to be discovered checkmate.
      legal_moves.should be_empty
      san_history.last.should eq "fxg6#"
    end
  end
end
