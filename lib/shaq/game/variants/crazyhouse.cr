module Shaq
  class CrazyhouseGame < Game
    class_property! reserves : Array(Piece?)
    property pockets = {
      Side::Black => Material.new(0),
      Side::White => Material.new(0),
    }

    def self.new
      super.tap &.add_tag "Variant", "Crazyhouse"
    end

    def initialize(*args)
      super
      fill_pockets!
      add_tag "Variant", "Crazyhouse"
    end

    def self.ranks_to_board(ranks)
      super.tap { |board| @@reserves = board.pop board.size - 64 }
    end

    def fill_pockets!
      self.class.reserves.each do |piece|
        pockets[piece.side][piece.type] += 1 if piece
      end
    end

    def update(*args)
      super

      if piece = @capture
        type = piece.promoted? ? Piece::Type::Pawn : piece.type
        pockets[other_side][type] += 1
      end
    end

    def algebraic_move(from, to)
      return super unless from < 0

      "#{PIECES.keys[from] if from < -1}@#{Util.to_algebraic to}"
    end

    def ply(from : Int32, to)
      return super unless from < 0
      raise IllegalMoveError.new "drop to occupied square" if occupied? to

      type = Piece::Type.from_value 6 + from
      raise IllegalMoveError.new "no #{type} to drop" if pockets[turn][type] < 1

      pockets[turn][type] -= 1
      board[to] = PIECES.values[from].new turn, to, self

      san_history << algebraic_move from, to
      @hm_clock = from == -1 ? 0 : hm_clock + 1
      @move += 1 if black?
      ply
    end

    def ply(move : String)
      return super unless move.match /(.?)@([a-h][1-8])/

      piece = {"": -1, N: -2, B: -3, R: -4, Q: -5}[$1]
      tap { ply piece, Util.from_algebraic $2 }
    end
  end

  class Game
    def crazyhouse?
      is_a? CrazyhouseGame
    end
  end
end
