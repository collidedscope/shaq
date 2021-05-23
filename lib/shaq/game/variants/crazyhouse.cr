module Shaq
  class CrazyhouseGame < Game
    variant "Crazyhouse"

    class_getter! reserves : Array(Piece?)
    getter pockets = {
      Side::Black => Material.new(0),
      Side::White => Material.new(0),
    }

    def initialize(*args)
      super
      add_tag "Variant", "Crazyhouse"
      fill_pockets!
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

    def legal_moves
      moves = super
      unoccupied = 64.times.reject(&->occupied?(Int32)).to_a
      unoccupied.reject! { |square| sim(-1, square).check? } if check?

      pockets[turn].each do |type, count|
        if count > 0
          moves.concat unoccupied.map { |square| {type.to_i - 6, square} }
        end
      end

      moves
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
      type = Piece::Type.from_value 6 + from

      if real?
        raise IllegalMoveError.new "drop to occupied square" if occupied? to
        raise IllegalMoveError.new "no #{type} to drop" if pockets[turn][type] < 1
      end

      board[to] = PIECES.values[from].new turn, to, self
      return self unless real?

      san_history << algebraic_move from, to
      pockets[turn][type] -= 1
      @hm_clock = from == -1 ? 0 : hm_clock + 1
      @move += 1 if black?
      ply
    end

    def ply(move : String)
      return super unless move.match /(.?)@([a-h][1-8])/

      piece = {"": -1, P: -1, N: -2, B: -3, R: -4, Q: -5}[$1]
      tap { ply piece, Util.from_algebraic $2 }
    end

    def write_ranks(io)
      reserves = pockets.map { |side, pocket|
        pocket.map { |type, count|
          Array.new count, type.letter side
        }
      }.flatten

      super
      io << "0 " << reserves.join(' ') << '\n'
    end
  end
end
