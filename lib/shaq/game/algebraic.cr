class Shaq::Game
  def algebraic_move(from, to)
    raise "No piece at #{from}!" unless piece = board[from]

    promo, to = to.divmod 64
    castling = piece.king? && (from - to).abs == 2

    String.build do |s|
      if piece.pawn?
        s << Square.new(from).file if board[to]
      elsif castling
        s << ({2, 58}.includes?(to) ? "O-O-O" : "O-O")
      else
        s << algebraic_piece piece, to
      end

      s << 'x' if board[to]
      s << Util.to_algebraic to unless castling
      s << '=' << "QNRB"[promo] if promo << 6 | to > 63

      g = sim(from, promo << 6 | to).ply
      s << (g.checkmate? ? '#' : g.check? ? '+' : "")
    end
  end

  def algebraic_piece(piece, target)
    String.build do |s|
      s << piece.letter.upcase
      candidates = friends piece.class
      candidates.select! { |c| legal_moves_for(c).includes? target }
      next if candidates.size == 1

      if candidates.count(&.file.== piece.file) == 1
        s << piece.file
      elsif candidates.count(&.rank.== piece.rank) == 1
        s << piece.rank
      else
        s << piece.file << piece.rank
      end
    end
  end
end
