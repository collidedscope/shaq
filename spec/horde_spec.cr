require "./spec_helper"
require "shaq/core_ext/enumerable"

describe HordeGame do
  it "sets up the board correctly" do
    subject HordeGame.new do
      pawns.tally(&.side).should eq({Side::Black => 8, Side::White => 36})
      pieces(Side::White).all? &.pawn?
    end
  end

  it "knows White has lost when their last piece is taken" do
    subject HordeGame.from_diagram <<-EOD do
      b - - 0 1
      8 . . . . . . . .
      7 . . . . . . . .
      6 . . . b . . . .
      5 . . . . . . . .
      4 . . . . . . . Q
      3 . . . . . n . .
      2 . . . . . . . .
      1 . . . . . . . k
        a b c d e f g h
      EOD
      ply F3, H4
      lost?.should be_true
      san_history.last.should eq "Nxh4#"
    end
  end
end
