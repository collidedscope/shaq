module Shaq
  abstract class Piece
    property! position : Int32, side : Side
    delegate black?, white?, to: side
    delegate color, rank, file, to: square

    ROYAL = [-9, -8, -7, -1, 1, 7, 8, 9]

    def initialize(@side : Side)
    end

    def friend?(other)
      other.try &.side.== side
    end

    def enemy?(other)
      other.try &.side.!= side
    end

    def moves(game)
      vision(game).reject { |square| friend? game.board[square] }
    end

    def square
      Square.new position
    end

    def promoting?
      pawn? && rank == PAWN_RANKS[side.other]
    end

    def reachable?(square)
      Util.inbounds? position, square
    end

    def reachable(offsets)
      offsets.map(&.+ position).select &->reachable?(Int32)
    end

    def traverse(board, heading)
      squares = [] of Int32
      now = position

      loop do
        target = now + heading
        break unless Util.inbounds? now, target
        squares << (now = target)
        break if board[now]
      end

      squares
    end

    {% for piece in %w[Pawn Rook Knight Bishop Queen King] %}
      def {{piece.downcase.id}}?
        is_a? {{piece.id}}
      end
    {% end %}

    def self.from_letter(c : Char)
      case c
      when 'p', 'P'; Pawn
      when 'r', 'R'; Rook
      when 'n', 'N'; Knight
      when 'b', 'B'; Bishop
      when 'q', 'Q'; Queen
      else           King
      end.new c.ascii_lowercase? ? Side::Black : Side::White
    end
  end

  class Pawn < Piece
    def vision(game)
      reachable white? ? [-9, -7] : [7, 9]
    end

    def moves(game)
      moves = vision(game).select { |square| enemy? game.board[square] }
      once, twice = white? ? [-8, -16] : [8, 16]

      if !game.board[position + once]
        moves << position + once
        if rank == PAWN_RANKS[side] && !game.board[position + twice]
          moves << position + twice
        end
      end

      if ep = game.ep_target
        moves << ep if vision(game).includes? ep
      end

      return moves if rank != PAWN_RANKS[game.other_side]
      moves.flat_map { |move| Array.new(4) { |i| i << 6 | move } }
    end
  end

  class Rook < Piece
    def vision(game)
      [-8, -1, 1, 8].flat_map { |heading| traverse game.board, heading }
    end
  end

  class Knight < Piece
    NEIGHBORS = [-17, -15, -10, -6, 6, 10, 15, 17]

    def vision(game)
      reachable NEIGHBORS
    end
  end

  class Bishop < Piece
    def vision(game)
      [-9, -7, 7, 9].flat_map { |heading| traverse game.board, heading }
    end
  end

  class Queen < Piece
    def vision(game)
      ROYAL.flat_map { |heading| traverse game.board, heading }
    end
  end

  class King < Piece
    def vision(game)
      reachable ROYAL
    end

    def moves(game)
      moves = super
      moves << LONG_CASTLE[side][:king] if can_castle? game, LONG_CASTLE
      moves << SHORT_CASTLE[side][:king] if can_castle? game, SHORT_CASTLE
      moves
    end

    def can_castle?(game, distance)
      return false if game.check?
      return false unless game.castling.includes? distance[side][:king]

      distance[side][:path].none? { |square|
        game.board[square] || game.attacked? square
      }
    end
  end

  {% for piece, offset in [King, Queen, Rook, Bishop, Knight, Pawn] %}
    class {{piece}}
      def symbol
        (0x265A + {{offset}}).chr
      end
    end
  {% end %}
end
