module Shaq
  abstract class Piece
    property! position : Int32, side : Side
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

    def rank
      Util.rank position
    end

    def file
      Util.file position
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
      (side == Side::White ? [-9, -7] : [7, 9]).map(&.+ position)
        .reject { |square| Util.teleport? position, square }
    end

    def moves(game)
      moves = vision(game).select { |square| enemy? game.board[square] }
      once, twice = side == Side::White ? [-8, -16] : [8, 16]

      if !game.board[position + once]
        moves << position + once
        if !game.board[position + twice] && rank == PAWN_RANKS[side]
          moves << position + twice
        end
      end

      return moves if Util.rank(position) != PAWN_RANKS[game.other_side]
      moves.flat_map { |move| Array.new(4) { |i| i << 6 | move } }
    end
  end

  class Rook < Piece
    def vision(game)
      [-8, -1, 1, 8].flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class Knight < Piece
    NEIGHBORS = [-17, -15, -10, -6, 6, 10, 15, 17]

    def vision(game)
      NEIGHBORS.map(&.+ position).reject { |square|
        square < 0 || square > 63 || Util.teleport? position, square
      }
    end
  end

  class Bishop < Piece
    def vision(game)
      [-9, -7, 7, 9].flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class Queen < Piece
    def vision(game)
      ROYAL.flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class King < Piece
    def vision(game)
      ROYAL.map(&.+ position).reject { |square|
        square < 0 || square > 63 || Util.teleport? position, square
      }
    end
  end

  {% for piece, letter in {Pawn: 'p', Rook: 'r', Knight: 'n', Bishop: 'b', Queen: 'q', King: 'k'} %}
    class {{piece}}
      def inspect(io)
        io << (side == Side::Black ? {{letter}} : {{letter}}.upcase)
      end
    end
  {% end %}
end
