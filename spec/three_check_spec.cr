require "./spec_helper"

describe ThreeCheckGame do
  it "knows the game is over when a King has been checked three times" do
    subject ThreeCheckGame.new do
      ply %w[d4 e5 dxe5 Bb4+ Bd2 Bxd2+ Kxd2]
      ply "Qg5"
      lost?.should be_true
    end
  end
end
