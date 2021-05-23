module Shaq
  class Game
    alias Position = Tuple(String, Side, Array(Int32), Int32?)

    property board : Array(Piece?)
    property tags = {} of String => String
    property? real = true
    getter \
      turn : Side,
      castling : Array(Int32),
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      capture : Piece?,
      san_history = [] of String,
      uci_history = [] of String,
      positions = Hash(Position, Int32).new(0)

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

    macro variant(name)
      def self.new
        super.tap &.add_tag "Variant", {{name}}
      end

      def initialize(*args)
        super
        add_tag "Variant", {{name}}
      end

      class Shaq::Game
        def {{name.downcase.tr("-", " ").split.join('_').id}}?
          is_a? {{@type}}
        end
      end

      VARIANTS[{{name}}] = self
    end
  end
end

require "shaq/game/**"
