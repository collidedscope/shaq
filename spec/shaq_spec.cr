require "csv"
require "./spec_helper"

describe Shaq do
  it "can create a Game representing the initial position" do
    new_game do
      board.size.should eq 64
      pieces.size.should eq 32
      turn.should eq Side::White
      legal_moves.size.should eq 20
    end
  end

  it "can solve 'hard' mate-in-one puzzles" do
    File.open "#{__DIR__}/fixtures/mate_in_one.csv" do |io|
      CSV.new io, headers: true do |puzzle|
        setup, solution = puzzle["moves"].split

        subject Game.from_fen puzzle["FEN"] do
          ply setup
          mates = legal_moves.select { |move| sim(*move).ply.checkmate? }
          mates.map { |m| Util.to_uci *m }.should contain solution
        end
      end
    end
  end
end
