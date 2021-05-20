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

    def self.unchecked_from_fen(board, fields)
      @@reserves = board.pop board.size - 64
      super.tap &.fill_pockets!
    end

    def fill_pockets!
      while piece = self.class.reserves.pop?
        pockets[piece.side][piece.type] += 1
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

      String.build do |s|
        s << PIECES.keys[from] if from < -1
        s << '@' << Util.to_algebraic to

        g = sim(from, to).ply
        s << (g.checkmate? ? '#' : g.check? ? '+' : "")
      end
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

      piece = {"": -1, P: -1, N: -2, B: -3, R: -4, Q: -5}[$1]
      tap { ply piece, Util.from_algebraic $2 }
    end
  end

  class Game
    def crazyhouse?
      is_a? CrazyhouseGame
    end
  end
end
