module Shaq::Util
  UCI = /^([a-h][1-8]){2}[qnrb]?/

  extend self

  def teleport?(from, to)
    (from % 8 - to % 8).abs > 2
  end

  def to_algebraic(position)
    raise "Invalid position: #{position}" unless (0..63) === position

    rank, file = position.divmod 8
    "#{'a' + file}#{8 - rank}"
  end

  def from_algebraic(square)
    raise "Invalid square: #{square}" unless square.match /^[a-h][1-8]$/

    file, rank = square.chars
    ('8' - rank) * 8 + (file - 'a')
  end

  def to_uci(from, to)
    promoting = to >= 64
    promo, to = to.divmod 64

    "#{to_algebraic from}#{to_algebraic to}#{"qnrb"[promo] if promoting}"
  end

  def from_uci(uci)
    raise "Invalid UCI: #{uci}" unless uci.match UCI

    from, to, promo = uci[0, 2], uci[2, 2], uci[4]?
    promo = promo ? "qnrb".index(promo).not_nil! : 0

    {from_algebraic(from), promo << 6 | from_algebraic(to)}
  end

  def traverse(board, piece, heading)
    squares = [] of Int32
    position = piece.position

    loop do
      target = position + heading
      break if !((0..63) === target) || teleport? position, target
      squares << (position = target)
      break if board[target]
    end

    squares
  end

  def fenalize(board)
    board.map { |piece|
      next '.' unless piece

      letter = Shaq::Game::LETTERS[piece.class].to_s
      piece.black? ? letter.downcase : letter
    }.join.scan(/.{8}/).map(&.[0].gsub /\.+/, &.size).join '/'
  end
end
