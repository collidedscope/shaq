require "./spec_helper"

describe Game do
  it "updates the state of the board as moves are played" do
    new_game do
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
    new_game do
      ply %w[e4 d5 Bb5]
      san_history.last.should eq "Bb5+"
      check?.should be_true
    end
  end

  it "knows when the King has nowhere to go" do
    new_game do
      ply %w[f3 e6 g4 Qh4#]
      checkmate?.should be_true
    end
  end

  it "knows about capturing en passant" do
    # https://en.wikipedia.org/wiki/En_passant#Unusual_examples
    subject Game.from_diagram <<-EOD do
      b - - 0 1
      8 . . . . . B . .
      7 . . . . . . p .
      6 . . . . . . . .
      5 . . . . R P . k
      4 . . . . p K . N
      3 . . . . . . P .
      2 . . . . q P . .
      1 . . . . . . . .
        a b c d e f g h
      EOD
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

  it "knows about castling" do
    new_game do
      multiply %w[e4 Nf3 Bc4]
      king.not_nil!.can_castle?(SHORT_CASTLE).should be_true

      # moving the King removes castling rights
      multiply %w[Ke2 Ke1]
      king.not_nil!.can_castle?(SHORT_CASTLE).should be_false

      ply # make it Black's turn
      multiply %w[d5 Bf5 Nc6 Qd7]
      king.not_nil!.can_castle?(LONG_CASTLE).should be_true

      sim("O-O-O").king.not_nil!.position.should eq C8
      multiply %w[Rb8 Ra8]

      # moving the Rook also removes castling rights
      king.not_nil!.can_castle?(LONG_CASTLE).should be_false
    end
  end
end
