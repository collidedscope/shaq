require "./spec_helper"

describe AntichessGame do
  it "forces a capture when at least one is possible" do
    subject AntichessGame.new do
      ply %w[e4 d5]
      legal_moves.should eq [{E4, D5}]
    end
  end
end
