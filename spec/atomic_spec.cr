require "./spec_helper"

# Test positions courtesy of: https://lichess.org/study/uf9GpQyI

describe AtomicGame do
  it "makes captures cause (potentially massive) explosions" do
    subject AtomicGame.from_diagram <<-EOD do
      b - - 0 1
      8 . . . . . . . .
      7 . . b p k . . .
      6 . . . . . . . .
      5 . . . . P . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . . . K . . . B
      1 . . . . . . . .
        a b c d e f g h
      EOD

      ply "d5"
      pieces.size.should eq 6
      ply "exd6"
      pieces.size.should eq 2

      checkmate?.should be_true
      san_history.last.should eq "exd6#"
    end
  end

  it "prevents friendly fire on the King" do
    subject AtomicGame.from_diagram <<-EOD do
      w - - 0 1
      8 . . . . . R . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . k . . .
      3 . . . . . p K .
      2 . . . . . . . .
      1 . . . . . . . .
        a b c d e f g h
      EOD

      expect_raises(IllegalMoveError) { ply "Rxf3" }
    end
  end

  it "allows Kings to be adjacent since they can't capture" do
    subject AtomicGame.from_diagram <<-EOD do
      w - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . K . . Q . .
      2 . . k . . . . .
      1 . . . . . . . .
        a b c d e f g h
      EOD

      check?.should be_false
      ply.check?.should be_false
    end
  end

  it "permits nonstandard ways to escape check" do
    subject AtomicGame.from_diagram <<-EOD do
      w KQkq - 0 1
      8 r n b q k . r .
      7 . p . . p . . p
      6 p . p p . p p .
      5 q . N . . . . .
      4 . . . P P . . .
      3 . . . . . . . .
      2 P P P . . P P P
      1 R . . Q K B . R
        a b c d e f g h
      EOD

      check?.should be_true
      legal_moves.should contain({F1, A6})
      sim(F1, A6).check?.should be_false
    end
  end

  it "knows that being one move away from exploded isn't necessarily check" do
    subject AtomicGame.from_diagram <<-EOD do
      w - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . k . . . b
      4 . . . . . . . .
      3 . . . . . . . .
      2 . . . . N . P .
      1 . . . K . . . .
        a b c d e f g h
      EOD

      check?.should be_false
    end
  end

  it "allows the King to be in the line of sight of powerless attackers" do
    subject AtomicGame.from_diagram <<-EOD do
      w - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . b
      4 . . . . . . . .
      3 . . . . . . . N
      2 . . . . . . P .
      1 . . k K . . . .
        a b c d e f g h
      EOD

      check?.should be_false
    end
  end

  it "prevents captures whose explosions would leave the King in check" do
    subject AtomicGame.from_diagram <<-EOD do
      w - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . b
      4 . . . . . N N .
      3 . . . . . . . N
      2 . . . . . . P .
      1 . k . K . . . .
        a b c d e f g h
      EOD

      expect_raises(IllegalMoveError) { ply "Nxf4" }
    end
  end

  it "understands that explosion beats check" do
    subject AtomicGame.from_diagram <<-EOD do
      b KQkq - 0 1
      8 r . b . k . n r
      7 p p . p Q . p p
      6 n . p . . p . .
      5 . B . . p . . .
      4 . P . . . . . q
      3 . . . . P . . .
      2 P . P P . P P P
      1 R N . . K . . R
        a b c d e f g h
      EOD

      check?.should be_true
      checkmate?.should be_false
      legal_moves_for(king).should be_empty
      legal_moves.should eq [{H4, F2}]
      ply(H4, F2).checkmate?.should be_true
    end
  end

  it "knows about atomic checkmate" do
    subject AtomicGame.from_diagram <<-EOD do
      b KQkq - 0 1
      8 r n . q k b . r
      7 p p p B p p p p
      6 . . . . . n . .
      5 . . . p . . . .
      4 . . . . . . b .
      3 . . . . P Q . .
      2 P P P P . P P P
      1 R N B . K . N R
        a b c d e f g h
      EOD

      checkmate?.should be_true
    end
  end

  it "knows about atomic stalemate" do
    subject AtomicGame.from_diagram <<-EOD do
      b - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . . . . . . Q Q
      1 . . . . . . k K
        a b c d e f g h
      EOD

      stalemate?.should be_true
    end
  end

  it "permits castling in surprisingly legal situations" do
    subject AtomicGame.from_diagram <<-EOD do
      w Q - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . . . . k . . .
      1 R . . . K . . q
        a b c d e f g h
      EOD

      king.can_castle?(itself, LONG_CASTLE).should be_true
      sim("O-O-O").king.position.should eq C1
    end
  end
end
