require "shaq/game/algebraic"
require "shaq/game/draw"
require "shaq/game/import_export"
require "shaq/game/material"
require "shaq/game/moves"
require "shaq/game/pieces"
require "shaq/game/status"

module Shaq
  class Game
    PIECES = {P: Pawn, R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      history = [] of String,
      positions = Hash(String, Int32).new(0),
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
      @initial_move = move
      history << "..." if black?
    end

    def self.new
      from_fen START
    end

    def sim(from, to)
      clone.ply from, to, false
    end

    def occupancy
      board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
    end

    def clone
      dup.tap &.board = board.map &.dup
    end
  end
end
