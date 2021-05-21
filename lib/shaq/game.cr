module Shaq
  class Game
    alias Position = Tuple(String, Side, Array(Int32), Int32?)

    property? real = true
    property \
      board : Array(Piece?),
      turn : Side,
      castling : Array(Int32),
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      capture : Piece?,
      san_history = [] of String,
      uci_history = [] of String,
      positions = Hash(Position, Int32).new(0),
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
      @initial_move = move
      san_history << "..." if black?
      own_pieces!
    end

    def self.new
      from_fen STANDARD
    end

    def own_pieces!
      board.each &.try &.game = self
    end

    macro inherited
      def self.new
        super.tap &.add_tag "Variant", variant
      end

      def initialize(*args)
        super
        add_tag "Variant", self.class.variant
      end

      VARIANTS[variant] = self
    end
  end
end

require "shaq/game/**"
