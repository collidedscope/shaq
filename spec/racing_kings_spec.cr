require "./spec_helper"

describe RacingKingsGame do
  it "sets up the board correctly" do
    subject RacingKingsGame.new do
      board.select(Pawn).should be_empty
      board[A8..H6].compact.should be_empty
    end
  end

  it "prevents moves which check the enemy King" do
    subject RacingKingsGame.new do
      expect_raises(IllegalMoveError) { ply "Nxc1" }
    end
  end

  it "has a different definition of checkmate" do
    subject RacingKingsGame.from_diagram <<-EOD do
      w - - 10 6
      8 . . . . . . . .
      7 . . . . . . K .
      6 . . k . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . r b n N B R .
      1 q r b n N B R Q
        a b c d e f g h
      EOD

      ply G7, H8
      checkmate?.should be_true
      san_history.last.should eq "Kh8#"
    end
  end

  it "knows about the draw condition" do
    subject RacingKingsGame.from_diagram <<-EOD do
      w - - 10 6
      8 . . . . . . . .
      7 . k . . . . K .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . r b n N B R .
      1 q r b n N B R Q
        a b c d e f g h
      EOD

      ply G7, H8
      checkmate?.should be_false
      ply B7, A8
      draw?.should be_true
    end
  end

  it "knows the last chance rule doesn't apply for White" do
    subject RacingKingsGame.from_diagram <<-EOD do
      b - - 10 6
      8 . . . . . . . .
      7 . k . . . . K .
      6 . . . . . . . .
      5 . . . . . . . .
      4 . . . . . . . .
      3 . . . . . . . .
      2 . r b n N B R .
      1 q r b n N B R Q
        a b c d e f g h
      EOD

      ply B7, A8
      checkmate?.should be_true
    end
  end

  it "knows the Black King must actually be able to reach the 8th rank" do
    subject RacingKingsGame.from_diagram <<-EOD do
      w - - 1 16
      8 . . . Q . . . .
      7 . k q . . R K .
      6 . . . . B . . .
      5 . . . . . . . .
      4 . . . . n . . .
      3 . . . . . . . .
      2 . . . . . . . .
      1 . . N n N . . .
        a b c d e f g h
      EOD

      ply G7, F8
      checkmate?.should be_true
    end
  end
end
