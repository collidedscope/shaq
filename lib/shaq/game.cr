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

    def legal_moves_for(piece)
      piece.moves(self).reject { |square| ply(piece.position, square, false).check? }
    end

    def ply
      @turn = turn == Side::Black ? Side::White : Side::Black
    end

    def ply(from, to, checked = true)
      if piece = board[from]
        unless !checked || legal_moves_for(piece).includes? to
          raise "Illegal move (#{from}->#{to})"
        end
        ply if checked
        tap { board[from], board[to] = nil, piece.tap &.position= to }
      else
        raise "No piece at #{from}!"
      end
    end

    def check?
      pieces = board.select Piece
      if king = pieces.find { |piece| piece.is_a? King && piece.side == turn }
        vision = pieces.select(&->king.enemy?(Piece)).flat_map &.vision self
        vision.includes? king.position
      else
        raise "No #{turn} King?!"
      end
    end

    def clone
      Game.new board, turn, castling, ep_target, hm_clock, move
    end

    def draw
      @board.each_slice 8 do |row|
        p row
      end
    end
  end
end
