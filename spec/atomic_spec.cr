require "./spec_helper"

# Test positions courtesy of: https://lichess.org/study/uf9GpQyI

describe AtomicGame do
  it "makes captures cause (potentially massive) explosions" do
    subject AtomicGame.from_fen "8/2bpk3/8/4P3/8/8/3K3B/8 b - - 0 1" do
      ply "d5"
      pieces.size.should eq 6
      ply "exd6"
      pieces.size.should eq 2

      checkmate?.should be_true
      san_history.last.should eq "exd6#"
    end
  end

  it "prevents friendly fire on the King" do
    subject AtomicGame.from_fen "5R2/8/8/8/4k3/5pK1/8/8 w - - 0 1" do
      expect_raises(IllegalMoveError) { ply "Rxf3" }
    end
  end

  it "allows Kings to be adjacent since they can't capture" do
    subject AtomicGame.from_fen "8/8/8/8/8/2K2Q2/2k5/8 w - - 0 1" do
      check?.should be_false
      ply.check?.should be_false
    end
  end

  it "permits nonstandard ways to escape check" do
    subject AtomicGame.from_fen "rnbqk1r1/1p2p2p/p1pp1pp1/q1N5/3PP3/8/PPP2PPP/R2QKB1R w KQkq - 0 1" do
      check?.should be_true
      legal_moves.should contain({F1, A6})
      ply(F1, A6).ply.check?.should be_false
    end
  end

  it "knows that being one move away from exploded isn't necessarily check" do
    subject AtomicGame.from_fen "8/8/8/3k3b/8/8/4N1P1/3K4 w - - 0 1" do
      check?.should be_false
    end
  end

  it "allows the King to be in the line of sight of powerless attackers" do
    subject AtomicGame.from_fen "8/8/8/7b/8/7N/6P1/2kK4 w - - 0 1" do
      check?.should be_false
    end
  end

  it "prevents captures whose explosions would leave the King in check" do
    subject AtomicGame.from_fen "8/8/8/7b/5NN1/7N/6P1/1k1K4 w - - 0 1" do
      expect_raises(IllegalMoveError) { ply "Nxf4" }
    end
  end

  it "understands that explosion beats check" do
    subject AtomicGame.from_fen "r1b1k1nr/pp1pQ1pp/n1p2p2/1B2p3/1P5q/4P3/P1PP1PPP/RN2K2R b KQkq - 0 1" do
      check?.should be_true
      checkmate?.should be_false
      legal_moves_for(king).should be_empty
      legal_moves.should eq [{H4, F2}]
      ply(H4, F2).checkmate?.should be_true
    end
  end

  it "knows about atomic checkmate" do
    subject AtomicGame.from_fen "rn1qkb1r/pppBpppp/5n2/3p4/6b1/4PQ2/PPPP1PPP/RNB1K1NR b KQkq - 0 1" do
      checkmate?.should be_true
    end
  end

  it "knows about atomic stalemate" do
    subject AtomicGame.from_fen "8/8/8/8/8/8/6QQ/6kK b - - 0 1" do
      stalemate?.should be_true
    end
  end
end
