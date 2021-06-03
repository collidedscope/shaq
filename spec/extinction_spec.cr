require "./spec_helper"

describe ExtinctionGame do
  it "knows that a piece type going extinct ends the game" do
    subject ExtinctionGame.from_diagram <<-EOD do
      b KQkq - 0 3
      8 r . b q k b . r
      7 p p p p p p p p
      6 . . Q . . n . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . P . . .
      2 P P P P . P P P
      1 R N B . K B N R
        a b c d e f g h
      EOD

      # White Queens go extinct.
      sim("dxc6").ply.checkmate?.should be_true

      # Alternatively, Black Knights go extinct.
      ply %w[e5 Qxf6]
      checkmate?.should be_true
    end
  end

  it "allows an unwise promotion to cause self-extinction" do
    subject ExtinctionGame.from_diagram <<-EOD do
      w - - 0 1
      8 k . . . n . . .
      7 q b . P . . . .
      6 . . . . . . . .
      5 r . . . . . . .
      4 . n . . . . . .
      3 . . . . . N . .
      2 . p . . . Q B .
      1 . . . . . . R K
        a b c d e f g h
      EOD

      # White takes the Knight on e8; Black still has a Knight, so it's not
      # extinction for them, but White is now out of Pawns and thus loses.
      sim("dxe8").checkmate?.should be_true
    end
  end

  it "knows that mutual extinction is a win for the attacking side" do
    subject ExtinctionGame.from_diagram <<-EOD do
      w - - 0 1
      8 k . . . r . . .
      7 q b . P . . . .
      6 . . . . . . . .
      5 n . . . . . . .
      4 . n . . . . . .
      3 . . . . . N . .
      2 . p . . . Q B .
      1 . . . . . . R K
        a b c d e f g h
      EOD

      # White's endling Pawn takes Black's endling Rook on e8; mutual
      # extinction events count as a loss for the attacked side.
      ply "dxe8"
      turn.should eq Side::Black
      checkmate?.should be_true

      ply
      turn.should eq Side::White
      checkmate?.should be_false
    end
  end
end
