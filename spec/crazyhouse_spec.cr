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
end
