require "./spec_helper"

describe CrazyhouseGame do
  it "puts material in the capturing side's pocket" do
    subject CrazyhouseGame.new do
      ply %w[Nc3 d5 Nxd5 Qxd5]
      pockets.should eq({
        Side::White => {Piece::Type::Pawn => 1},
        Side::Black => {Piece::Type::Knight => 1},
      })
    end
  end

  it "demotes promoted pieces before pocketing them" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQkq - 1 5
      8 r n . q k b . r
      7 P b . p p p p p
      6 . . . . . n . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 P P P . P P P P
      1 R N B Q K B N R
        a b c d e f g h
      EOD
      ply "axb8=Q"
      pockets[Side::White].should eq({Piece::Type::Knight => 1})

      ply "Qxb8"
      pockets[Side::Black].should eq({Piece::Type::Pawn => 1})
    end
  end

  it "reads the 0th rank of a FEN string to populate the pockets" do
    subject CrazyhouseGame.from_fen "r2q1k1r/1pp3p1/p6p/8/8/8/PPnPPNPb/1RBK1B1R/NPNPPbpppq b - - 9 26" do
      pockets[Side::White][Piece::Type::Knight].should eq 2
      pockets[Side::Black][Piece::Type::Pawn].should eq 3
    end
  end

  it "can read the 0th rank when constructing from a diagram" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQkq - 1 5
      8 r n . q k b . r
      7 P b . p p p p p
      6 . . . . . n . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 P P P . P P P P
      1 R N B Q K B N R
      0 N B p p p N
        a b c d e f g h
      EOD
      pockets[Side::Black].should eq({Piece::Type::Pawn => 3})
      pockets[Side::White].should eq({
        Piece::Type::Bishop => 1,
        Piece::Type::Knight => 2,
      })
    end
  end

  it "allows pieces to be dropped from the pocket" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQkq - 0 4
      8 r . b . k b n r
      7 p p p . p p p p
      6 . . n . . . . .
      5 . . . q . . . .
      4 . . . P . . . .
      3 . . . . . . . .
      2 P P P . P P P P
      1 R . B Q K B N R
      0 n P
        a b c d e f g h
      EOD
      ply -1, 11
      check?.should be_true
      san_history.last.should eq "@d7+"
      pockets[Side::White][Piece::Type::Pawn].should eq 0
    end
  end

  it "ensures the pocket actually contains the piece being dropped" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQkq - 0 4
      8 r n b q k b n r
      7 p p p p p p p p
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 P P P P P P P P
      1 R N B Q K B N R
      0
        a b c d e f g h
      EOD
      expect_raises(IllegalMoveError, "no Knight to drop") { ply "N@d4" }
    end
  end

  it "knows drops are allowed to block check" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQkq - 0 1
      8 r n b . k b n r
      7 p p . p p p p p
      6 . . . . . . . .
      5 . . P . . . . .
      4 . . . . . . . .
      3 . . q . . . . .
      2 . . . . P P P P
      1 . . . B K B N R
      0 R P N
        a b c d e f g h
      EOD
      check?.should be_true
      legal_moves.sort.should eq [{-4, 51}, {-2, 51}, {-1, 51}]
      ply "R@d2"
      check?.should be_false
    end
  end

  it "knows drops are allowed to checkmate the King" do
    subject CrazyhouseGame.from_diagram <<-EOD do
      w KQ - 46 24
      8 . . . . . k . r
      7 p b . r n . p p
      6 n p p . P b . .
      5 . . . . Q P . .
      4 . . . . . . . .
      3 . . P . . . P N
      2 P . P P B P P P
      1 R . B . K . . R
      0 p Q N
        a b c d e f g h
      EOD
      ply -5, F7
      checkmate?.should be_true
      san_history.last.should eq "Q@f7#"
    end
  end
end
