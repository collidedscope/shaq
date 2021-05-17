class Shaq::Game
  def clone
    dup.tap { |fake|
      fake.board = board.map &.dup
      fake.real = false
    }
  end

  def sim(*args)
    clone.ply *args
  end

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

  def update(from, to, irreversible)
    san_history << algebraic_move from, to
    uci_history << Util.to_uci from, to
    @hm_clock = irreversible ? 0 : hm_clock + 1
    @move += 1 if black?
    ply

    castling.delete 2 if {0, 4}.includes? from
    castling.delete 6 if {4, 7}.includes? from
    castling.delete 58 if {56, 60}.includes? from
    castling.delete 62 if {60, 63}.includes? from
  end

  def ply
    tap { @turn = other_side }
  end

  def ply(from, to)
    raise "Game is over!" if real? && over?
    raise "No piece at #{from}!" unless piece = board[from]
    raise IllegalMoveError.new from, to unless !real? || can_move? piece, to

    board.swap to, to + (white? ? 8 : -8) if piece.pawn? && to == @ep_target
    @ep_target = nil

    if piece.pawn?
      @ep_target = to + (white? ? 8 : -8) if (from - to).abs == 16

      if piece.promoting?
        promo, to = to.divmod 64
        piece = {Queen, Knight, Rook, Bishop}[promo].new turn, to
      end
    end

    if piece.king? && (from - to).abs == 2
      castle = {2, 58}.includes?(to) ? LONG_CASTLE : SHORT_CASTLE
      a, b = castle[turn][:rook]
      board[a], board[b] = nil, Rook.new turn, b
    end

    irreversible = piece.pawn? || board[to]
    update from, (promo || 0) << 6 | to, irreversible if real?

    board[from], board[to] = nil, piece.tap &.position = to
    positions[position] += 1 if real? unless irreversible
    self
  end

  def ply(piece : Piece, target)
    ply piece.position, target
  end

  def ply(move : String)
    return ply *Util.from_uci move if move.match UCI
    san = move

    return ply king, LONG_CASTLE[turn][:king] if san["O-O-O"]?
    return ply king, SHORT_CASTLE[turn][:king] if san["O-O"]?

    if square = san[/^([a-h][1-8])/]?
      piece = friends(Pawn).find { |p| can_move? p, square }
    elsif move = san.match /(.+)x?([a-h][1-8])/
      _, mover, square = move
      rank = file = nil

      candidates = friends PIECES[mover[0, 1]]? || Pawn
      candidates.select! &.rank.== rank.to_i if rank = mover[/[1-8]/]?
      candidates.select! &.file.== file[0] if file = mover[/[a-h]/]?

      piece = candidates.find { |c| can_move? c, square }
    else
      raise InvalidMoveError.new san
    end

    raise IllegalMoveError.new san unless piece

    target = Util.from_algebraic square
    target |= "QNRB".index($1).not_nil! << 6 if san.match(/=([QNRB])/)
    ply piece, target
  end

  def ply(moves : Array(String))
    tap { moves.each &->ply(String) }
  end
end
