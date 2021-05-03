module Shaq
  enum Side
    Black; White
  end

  BACK_RANKS = {Side::White => 1, Side::Black => 8}
  PAWN_RANKS = {Side::White => 2, Side::Black => 7}

  def self.load_pgn(path)
    games = [] of Game

    File.open path do |io|
      while game = Game.from_pgn_io io
        games << game
      end
    end

    games
  end
end

require "shaq/util"
require "shaq/game"
require "shaq/piece"
