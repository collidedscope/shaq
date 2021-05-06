module Shaq
  enum Side
    Black
    White

    def other
      Side.new 1 - to_i
    end
  end

  BACK_RANKS = {Side::White => 1, Side::Black => 8}
  PAWN_RANKS = {Side::White => 2, Side::Black => 7}

  LONG_CASTLE = {
    Side::Black => {king: 2, path: 2..3, rook: {0, 3}},
    Side::White => {king: 58, path: 58..59, rook: {56, 59}},
  }
  SHORT_CASTLE = {
    Side::Black => {king: 6, path: 5..6, rook: {7, 5}},
    Side::White => {king: 62, path: 61..62, rook: {63, 61}},
  }

  def self.load_pgn(path)
    games = [] of Game

    File.open path do |io|
      while game = Game.from_pgn_io io
        games << game
      end
    end

    games
  end

  def self.load_pgn(path)
    File.open path do |io|
      while game = Game.from_pgn_io io
        yield game
      end
    end
  end
end

require "shaq/util"
require "shaq/game"
require "shaq/piece"
