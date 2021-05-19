module Shaq
  alias Material = Hash(Piece::Type, Int32)

  abstract class Piece
    property side : Side, position : Int32
    property! game : Game

    delegate black?, white?, to: side
    delegate color, rank, file, to: square

    enum Type
      {% for piece in PIECES.values %} {{piece}}; {% end %}
    end

    def initialize(@side, @position, @game = nil)
    end

    def friend?(other)
      other.try &.side.== side
    end

    def enemy?(other)
      other.try &.side.!= side
    end

    def moves
      vision.reject { |square| friend? game.board[square] }
    end

    def square
      Square.new position
    end

    def promoting?
      pawn? && rank == PAWN_RANKS[side.other]
    end

    def traverse(heading)
      squares = [] of Int32
      now = position

      loop do
        target = now + heading
        break unless Util.inbounds? now, target
        squares << (now = target)
        break if game.board[now]
      end

      squares
    end

    def slider_vision(headings)
      headings.flat_map { |heading| traverse heading }
    end

    {% for piece in %w[Pawn Rook Knight Bishop Queen King] %}
      def {{piece.downcase.id}}?
        is_a? {{piece.id}}
      end
    {% end %}

    def self.from_letter(c, position)
      case c
      when 'p', 'P'; Pawn
      when 'r', 'R'; Rook
      when 'n', 'N'; Knight
      when 'b', 'B'; Bishop
      when 'q', 'Q'; Queen
      when 'k', 'K'; King
      else           return nil
      end.new c.ascii_lowercase? ? Side::Black : Side::White, position
    end
  end

  class Pawn < Piece
    def vision
      PAWN_VISION[side][position]
    end

    def moves
      moves = vision.select { |square| enemy? game.board[square] }
      forward = black? ? 8 : -8

      if !game.board[square = position + forward]
        moves << square
        twice = game.horde? && white? ? rank < 3 : rank == PAWN_RANKS[side]
        twice &&= !game.board[square += forward]
        moves << square if twice
      end

      if ep = game.ep_target
        moves << ep if vision.includes? ep
      end

      return moves if rank != PAWN_RANKS[game.other_side]
      moves.flat_map { |move| Array.new(4) { |i| i << 6 | move } }
    end
  end

  class Rook < Piece
    def vision
      slider_vision [-8, -1, 1, 8]
    end
  end

  class Knight < Piece
    def vision
      KNIGHT_VISION[position]
    end
  end

  class Bishop < Piece
    def vision
      slider_vision [-9, -7, 7, 9]
    end
  end

  class Queen < Piece
    def vision
      slider_vision ROYAL
    end
  end

  class King < Piece
    def vision
      Util.moore_neighborhood position
    end

    def moves
      moves = super
      moves << LONG_CASTLE[side][:king] if can_castle? LONG_CASTLE
      moves << SHORT_CASTLE[side][:king] if can_castle? SHORT_CASTLE

      # TODO: This could be cleaner if the &-> sugar did property lookup.
      moves.reject! { |square| game.occupied? square } if game.atomic?
      moves
    end

    def can_castle?(distance)
      return false if game.check?
      return false unless game.castling.includes? distance[side][:king]

      distance[side][:path].none? { |square|
        game.board[square] || game.attacked? square
      }
    end
  end

  {% for piece, offset in PIECES.values %}
    class {{piece}}
      def type
        Type::{{piece}}
      end

      def letter
        "kqrbnpKQRBNP"[side.value * 6 + {{offset}}]
      end

      def symbol
        '♚' + {{offset}}
      end

      def sided_symbol
        symbol - 6 * side.value
      end
    end
  {% end %}
end
