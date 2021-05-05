class Shaq::Game
  def legal_moves_for(piece) : Array(Int32)
    piece.moves(self).reject { |square| sim(piece.position, square).check? }
  end

  def legal_moves
    friends.flat_map { |piece|
      legal_moves_for(piece).map { |move| {piece.position, move} }
    }
  end

  def can_move?(piece, square)
    legal_moves_for(piece).includes? square
  end

  def can_move?(piece, square : String)
    can_move? piece, Util.from_algebraic square
  end

  def ply
    tap { @turn = other_side }
  end

  def ply(from, to, real = true)
    raise "Game is over!" if real && over?
    raise "No piece at #{from}!" unless piece = board[from]
    raise "Illegal move: #{from}->#{to}" unless !real || can_move? piece, to

    board.swap to, to + (white? ? 8 : -8) if piece.pawn? && to == @ep_target
    @ep_target = nil

    if piece.pawn?
      @ep_target = to + (white? ? 8 : -8) if (from - to).abs == 16

      if Util.rank(to % 64) == BACK_RANKS[other_side]
        promo, to = to.divmod 64
        piece = {Queen, Knight, Rook, Bishop}[promo].new turn
      end
    end

    irreversible = piece.pawn? || board[to]

    if real
      history << algebraic_move from, (promo || 0) << 6 | to
      @hm_clock = irreversible ? 0 : hm_clock + 1
      @move += 1 if black?
      ply

      # TODO: take other factors into account (castling, en passant, turn)
      positions[Util.fenalize board] += 1 unless irreversible
    end

    tap { board[from], board[to] = nil, piece.tap &.position = to }
  end

  # TODO: Handle castling.
  def ply(san)
    rank = file = nil

    if square = san[/^([a-h][1-8])/]?
      piece = friends(Pawn).find { |p| can_move? p, square }
    elsif move = san.match /(.+?)x?([a-h][1-8])/
      _, mover, square = move

      candidates = friends PIECES[mover[0, 1]]? || Pawn
      candidates.select! &.rank.== rank.to_i if rank = mover[/[1-8]/]?
      candidates.select! &.file.== file[0] if file = mover[/[a-h]/]?

      piece = candidates.find { |c| can_move? c, square }
    end

    raise "Invalid or illegal move: #{san}" unless piece && square

    target = Util.from_algebraic square
    target |= "QNRB".index($1).not_nil! << 6 if san.match(/=([QNRB])/)
    ply piece.position, target
  end
end