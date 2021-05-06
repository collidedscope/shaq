require "shaq/game/*"

module Shaq
  class Game
    PIECES = {P: Pawn, R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}

    alias Position = Tuple(String, Side, Array(Int32), Int32?)

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      history = [] of String,
      positions = Hash(Position, Int32).new(0),
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
      @initial_move = move
      history << "..." if black?
    end

    def self.new
      from_fen START
    end
  end
end
