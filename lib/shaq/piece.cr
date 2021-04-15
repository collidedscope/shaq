module Shaq
  abstract class Piece
    property! position : Int32

    def initialize(@side : Side)
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
  end

  class Rook < Piece
  end

  class Knight < Piece
  end

  class Bishop < Piece
  end

  class Queen < Piece
  end

  class King < Piece
  end

  {% for piece, letter in {Pawn: 'p', Rook: 'r', Knight: 'n', Bishop: 'b', Queen: 'q', King: 'k'} %}
    class {{piece}}
      def inspect(io)
        io << (@side == Side::Black ? {{letter}} : {{letter}}.upcase)
      end
    end
  {% end %}
end
