module Shaq
  abstract class Piece
    property! position : Int32, side : Side
    ROYAL = [-9, -8, -7, -1, 1, 7, 8, 9]

    def initialize(@side : Side)
    end

    def friendly?(other)
      other.try &.side == side
    end

    def enemy?(other)
      !friendly? other
    end

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
    property? moved = false

    def legal_moves(game)
      [] of Int32
    end
  end

  class Rook < Piece
    property? moved = false

    def legal_moves(game)
      [-8, -1, 1, 8].flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class Knight < Piece
    NEIGHBORS = [-17, -15, -10, -6, 6, 10, 15, 17]

    def legal_moves(game)
      NEIGHBORS.map(&.+ position).select(0..63).reject { |square|
        Util.teleport?(position, square) || friendly? game.board[square]
      }
    end
  end

  class Bishop < Piece
    def legal_moves(game)
      [-9, -7, 7, 9].flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class Queen < Piece
    def legal_moves(game)
      ROYAL.flat_map { |heading| Util.traverse game.board, self, heading }
    end
  end

  class King < Piece
    property? moved = false

    def legal_moves(game)
      threatened = game.board.select(Piece)
        .select(&.enemy? self).reject(King).flat_map(&.legal_moves game)

      ROYAL.map(&.+ position).select(0..63).reject { |square|
        Util.teleport?(position, square) || friendly? game.board[square]
      } - threatened
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
