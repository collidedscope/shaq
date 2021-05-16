require "shaq/game/**"

module Shaq
  class Game
    alias Position = Tuple(String, Side, Array(Int32), Int32?)

    property \
      board : Array(Piece?),
      turn : Side,
      castling : Array(Int32),
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      real = true,
      san_history = [] of String,
      uci_history = [] of String,
      positions = Hash(Position, Int32).new(0),
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
      @initial_move = move
      san_history << "..." if black?
    end

    def self.new
      from_fen STANDARD
    end
  end
end
