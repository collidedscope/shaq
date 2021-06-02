module Shaq
  class InvalidFenError < Exception
    def initialize(message)
      super "Invalid FEN: #{message}"
    end
  end

  class InvalidMoveError < Exception
    def initialize(move)
      super "Invalid move: #{move}"
    end
  end

  class IllegalMoveError < Exception
    def initialize(move)
      super "Illegal move: #{move}"
    end

    def initialize(from, to)
      super "Illegal move: #{Util.to_algebraic from} -> #{Util.to_algebraic to & 63}"
    end
  end
end
