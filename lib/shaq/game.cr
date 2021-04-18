module Shaq
  class Game
    START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : String,
      hm_clock : Int32,
      move : Int32

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
    end

    def self.from_fen(fen)
      ranks, turn, castling, ep_target, hm_clock, move = fen.split

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index { |c, i|
        Piece.from_letter(c).tap &.position = i if c != '.'
      }
      turn = {b: Side::Black, w: Side::White}[turn]

      new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
    end

    def self.new
      from_fen START
    end

    # TODO: reject moves which would leave the King in check
    def legal_moves_for(piece)
      moves = piece.moves self
    end

    def draw
      @board.each_slice 8 do |row|
        p row
      end
    end
  end
end
