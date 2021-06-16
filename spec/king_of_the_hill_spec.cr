require "./spec_helper"

describe KingoftheHillGame do
  it "knows the game is over when a King has reached the center" do
    subject KingoftheHillGame.new do
      ply %w[d3 e5 Kd2 c5 Ke3 Nc6]
      ply "Ke4"
      lost?.should be_true
      san_history.last.should eq "Ke4#"
    end
  end
end
