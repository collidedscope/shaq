class Shaq::Game
  # TODO: Handle castling.
  def algebraic_move(from, to)
    raise "No piece at #{from}!" unless piece = board[from]

    promoting = piece.pawn? && piece.rank == PAWN_RANKS[other_side]
    promo, to = to.divmod 64

    String.build do |s|
      case piece
      when Pawn
        s << Util.file from if board[to]
      else
        s << algebraic_piece piece, to
      end

      s << 'x' if board[to]
      s << Util.to_algebraic to
      s << '=' << "QNRB"[promo] if promoting

      g = sim(from, promo << 6 | to).ply
      if g.checkmate?
        s << '#'
      elsif g.check?
        s << '+'
      end
    end
  end

  def algebraic_piece(piece, target)
    String.build do |s|
      s << LETTERS[piece.class]
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
