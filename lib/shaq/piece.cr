module Shaq
  alias Material = Hash(Piece::Type, Int32)

  abstract class Piece
    property side : Side
    property position : Int32
    property? promoted = false
    property! game : Game

    delegate black?, white?, to: side
    delegate color, rank, file, to: square

    enum Type
      {% for piece in PIECES.values %} {{piece}}; {% end %}

      def letter(side)
        "kqrbnpKQRBNP"[side.value * 6 + value]
      end
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

    def cloak
      nil
    end

    def disrobe
      self
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
      n = game.extinction? ? 5 : 4
      moves.flat_map { |move| Array.new(n) { |i| i << 6 | move } }
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

      def encloak(piece)
        piece = piece.disrobe unless game.as(CloakDaggerGame).mode.stack?
        pc = c = Cloaked{{piece}}.new(side, position, game).tap &.cloak= piece

        # Cloaks can stack, so we need to update the entire chain.
        while c = c.cloak
          c.side = side
        end

        pc
      end
    end

    class Cloaked{{piece}} < {{piece}}
      property! cloak : Piece

      def vision
        other = cloak.tap(&.game = game).vision
        if game.as(CloakDaggerGame).mode.replace?
          other
        else
          super | other
        end
      end

      def disrobe
        {{piece}}.new side, position, game
      end

      def moves
        other = cloak.tap(&.game = game).moves.reject &.> 63
        if game.as(CloakDaggerGame).mode.replace?
          other
        else
          super | other
        end
      end
    end
  {% end %}

  class CloakedPawn
    def moves
      n = game.extinction? ? 5 : 4
      previous_def.flat_map { |move|
        next move if 8 - move // 8 != BACK_RANKS[side.other]
        Array.new(n) { |i| i << 6 | move }
      }
    end
  end
end
