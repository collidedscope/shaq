require "./spec_helper"

describe CloakDaggerGame do
  it "makes capturing pieces 'wear' the captured piece for one turn" do
    subject CloakDaggerGame.new do
      ply %w[d4 Nc6 Bh6]

      # Now the Pawn on g7 can take the Bishop on h6 and gain its powers.
      ply "gxh6"
      board[H6].not_nil!.moves.should contain E3

      ply "e3"
      ply H6, E3

      # The Pawn was able to act as a Bishop, but the effect has now worn off.
      board[E3].not_nil!.moves.sort.should eq [E2, F2]
    end
  end

  it "knows cloaking can cause check" do
    subject CloakDaggerGame.from_diagram <<-EOD do
      w KQkq - 0 3
      8 r n b q k b . r
      7 p p p p p p . p
      6 . . . . . n p .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . P . . . . . .
      2 P B P P P P P P
      1 R N . Q K B N R
        a b c d e f g h
      EOD
      ply "Bxf6"
      check?.should be_true
      legal_moves.should eq [{E7, F6}]
    end
  end

  it "allows cloaks to 'stack'" do
    subject CloakDaggerGame.from_diagram <<-EOD do
      b - - 0 1
      8 k . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . p . . . .
      4 . . . . N . . .
      3 . . . . . . . .
      2 . . Q . . . . .
      1 . . . . . . . K
        a b c d e f g h
      EOD
      # Pawn takes the Knight, and can thus make Knight moves.
      ply "dxe4"
      board[E4].not_nil!.moves.size.should eq 9

      # Queen then takes the Knight-cloaked Pawn.
      ply "Qxe4"
      board[E4].not_nil!.moves.should contain D6
    end
  end

  it "permits Pawns to promote regardless of how they reach the back rank" do
    subject CloakDaggerGame.from_diagram <<-EOD do
      b Kkq - 2 3
      8 r n b q k . n r
      7 p p p p p p b p
      6 . . . . . . p .
      5 . . . . . . . .
      4 P . . . . . . P
      3 R . . . . . . .
      2 . P P P P P P .
      1 . N B Q K B N R
        a b c d e f g h
      EOD
      # an unfortunate mouse-slip
      ply "Bc3"
      # Pawn encloaks the Bishop, eyeing the Rook.
      ply "bxc3"
      # another slip
      ply "Nh6"
      # Pawn can now take the Rook and promote (here to a Knight).
      ply C3, H8 | KnightP

      board[H8].not_nil!.should be_a CloakedKnight
      check?.should be_true # since it's cloaking a Rook
    end
  end

  it "doesn't let non-Pawns use their Pawn cloak to promote" do
    subject CloakDaggerGame.from_diagram <<-EOD do
      w - - 0 1
      8 k . . . . . . .
      7 . . p . . . . .
      6 . . . . . . . .
      5 . . . N . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . . . P . . . .
      1 . . . . . . . K
        a b c d e f g h
      EOD
      ply "Nxc7+"
      ply "Ka7"

      board[C7].not_nil!.moves.should contain C8
      expect_raises(IllegalMoveError) { ply C7, C8 | RookP }
    end
  end
end
