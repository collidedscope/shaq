require "./spec_helper"
require "shaq/core_ext/enumerable"

describe HordeGame do
  it "sets up the board correctly" do
    subject HordeGame.new do
      pawns.tally(&.side).should eq({Side::Black => 8, Side::White => 36})
      pieces(Side::White).all? &.pawn?
    end
  end
end
